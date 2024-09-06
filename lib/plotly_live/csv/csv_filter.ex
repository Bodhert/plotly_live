defmodule PlotlyLive.Csv.CsvFilter do
  alias NimbleCSV.RFC4180, as: CSV

  def parse_csv(csv_string, filters \\ []) do
    csv_string
    |> CSV.parse_string(skip_headers: false)
    |> enumerate()
    |> apply_filters(filters)
  end

  defp enumerate(csv) do
    Enum.map(csv, fn row -> Enum.with_index(row) end)
  end

  defp apply_filters(csv, []), do: {:ok, csv}

  defp apply_filters([header | rows], filters) do
    filter_map =
      Enum.into(header, %{})
      |> Map.take(filters)
      |> Enum.into(%{}, fn {key, value} -> {value, key} end)

    result_csv =
      Enum.map(rows, fn row ->
        Enum.flat_map(row, fn {value, index} ->
          if filter_map[index], do: [value], else: []
        end)
      end)

    if Enum.at(result_csv, 0) == [] do
      []
    else
      result_csv
    end
  end
end
