alias PlotlyLive.Csv.CsvManager
alias PlotlyLive.Csv.CsvFilter

{:ok, body} = CsvManager.download_file("1962_2006_walmart_store_openings.csv")
CsvFilter.parse_csv(body)
