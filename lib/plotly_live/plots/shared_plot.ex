defmodule PlotlyLive.SharedPlot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shared_plots" do

    field :plot_id, :id
    field :shared_with_user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shared_plot, attrs) do
    shared_plot
    |> cast(attrs, [])
    |> validate_required([])
  end
end
