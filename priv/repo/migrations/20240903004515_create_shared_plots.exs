defmodule PlotlyLive.Repo.Migrations.CreateSharedPlots do
  use Ecto.Migration

  def change do
    create table(:shared_plots) do
      add :plot_id, references(:plots, on_delete: :nothing)
      add :shared_with_user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:shared_plots, [:plot_id])
    create index(:shared_plots, [:shared_with_user_id])
  end
end
