defmodule PlotlyLive.Repo do
  use Ecto.Repo,
    otp_app: :plotly_live,
    adapter: Ecto.Adapters.Postgres
end
