defmodule PlotlyLiveWeb.PlotLive.Index do
  use PlotlyLiveWeb, :live_view

  alias PlotlyLive.Plots
  alias PlotlyLive.Plots.Plot

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     stream(socket, :plots, Plots.list_plots()) |> assign(user_id: socket.assigns.current_user.id)}
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
  def handle_event("delete", %{"id" => id}, socket) do
    plot = Plots.get_plot!(id)
    {:ok, _} = Plots.delete_plot(plot)

    {:noreply, stream_delete(socket, :plots, plot)}
  end

  def handle_event("chart_ready", _, socket) do
    {:reply, %{data: [1, 1]}, socket}
  end
end
