defmodule PlotlyLive.Plots.Plot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plots" do
    field :name, :string
    field :dataset_name, :string
    field :expression, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plot, attrs) do
    plot
    |> cast(attrs, [:user_id, :name, :dataset_name, :expression])
    |> validate_required([:user_id, :name, :dataset_name, :expression])
  end
end
