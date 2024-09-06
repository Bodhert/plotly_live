defmodule PlotlyLiveWeb.PlotLive.Index do
  require Logger
  use PlotlyLiveWeb, :live_view

  alias PlotlyLive.Plots
  alias PlotlyLive.Plots.Plot
  alias PlotlyLive.Csv.CsvManager
  alias PlotlyLive.Csv.CsvFilter

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     stream(socket, :plots, Plots.list_plots(socket.assigns.current_user.id))
     |> assign(user_id: socket.assigns.current_user.id)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Plot")
    |> assign(:plot, Plots.get_plot!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Plot")
    |> assign(:plot, %Plot{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Plots")
    |> assign(:plot, nil)
  end

  @impl true
  def handle_info({PlotlyLiveWeb.PlotLive.FormComponent, {:saved, plot}}, socket) do
    {:noreply, stream_insert(socket, :plots, plot)}
  end

  @impl true
  def handle_info({PlotlyLiveWeb.PlotLive.FormComponent, {:filter, plot_params}}, socket) do
    {:noreply,
     socket
     |> start_async(:download_csv, fn ->
       case CsvManager.download_file(plot_params["dataset_name"]) do
         {:ok, {:ok, csv}} ->
           CsvFilter.parse_csv(csv, plot_params["expression"])

         {:ok, csv} ->
           CsvFilter.parse_csv(csv, [plot_params["expression"]])

         {:error, error} ->
           Logger.error(error)
       end
     end)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    plot = Plots.get_plot!(id)
    {:ok, _} = Plots.delete_plot(plot)

    {:noreply, stream_delete(socket, :plots, plot)}
  end

  @impl true
  def handle_async(:download_csv, {:ok, []}, socket) do
    Logger.info("No filter where successful")
    {:noreply, socket}
  end

  def handle_async(:download_csv, {:ok, result}, socket) do
    result = List.flatten(result)

    {:noreply, push_event(socket, "point_added", %{data: result})}
  end

  def handle_async(:download_csv, {:error, reason}, socket) do
    {:noreply, socket}
  end

  def handle_async(:apply_filters, {:ok, filtered_csv}, socket) do
    flattened_list =
      filtered_csv
      |> List.flatten()

    {:noreply, push_event(socket, "point_added", %{data: flattened_list})}
  end
end
