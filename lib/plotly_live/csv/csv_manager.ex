defmodule PlotlyLive.Csv.CsvManager do
  require Logger

  # for test 1962_2006_walmart_store_openings.csv
  # TODO: the url can go in Enviroment variables
  @url "https://raw.githubusercontent.com/plotly/datasets/master"
  @cache :csv_cache

  def get_file(path) do
    case Cachex.get(@cache, path) do
      {:ok, nil} ->
        async_download_file(path)
        {:ok, :downloading}

      {:ok, file} ->
        Logger.info("cache hit")
        {:ok, file}

      {error, reason} ->
        {error, reason}
    end
  end

  def async_download_file(path) do
    caller_pid = self()

    Task.start(fn ->
      case download_file(path) do
        {:ok, body} ->
          send(caller_pid, {:task_completed, body})

        {:error, error} ->
          Logger.error("#{error}")
          send(caller_pid, {:error})
      end
    end)
  end

  def download_file(path) do
    with {:ok, nil} <- Cachex.get(@cache, path) do
      case HTTPoison.get("#{@url}/#{path}") do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          Cachex.put(@cache, path, body)
          {:ok, body}

        {:ok, %HTTPoison.Response{status_code: code}} when code in 400..599 ->
          {:error, :bad_response}

        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, reason}
      end
    else
      {:ok, file} ->
        Logger.info("cache hit")
        {:ok, file}

      {error, reason} ->
        {error, reason}
    end
  end
end
