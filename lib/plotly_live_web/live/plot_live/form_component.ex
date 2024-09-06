defmodule PlotlyLiveWeb.PlotLive.FormComponent do
  use PlotlyLiveWeb, :live_component

  alias PlotlyLive.Plots

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Plot</:subtitle>
      </.header>
      <%!-- <script src="https://cdn.plot.ly/plotly-latest.min.js">
      </script> --%>
      <%= if @id != :new do %>
        <div
          class="max-w-full max-h-full overflow-auto bg-white"
          id="chart"
          phx-update="ignore"
          phx-hook="Chart"
        >
        </div>
      <% end %>
      <.simple_form
        for={@form}
        id="plot-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" placeholder="name" required />
        <.input field={@form[:dataset_name]} type="text" placeholder="dataset name" required />
        <.input field={@form[:expression]} type="text" placeholder="expression" required />

        <:actions>
          <.button phx-disable-with="Saving...">Save Plot</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{plot: plot} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Plots.change_plot(plot))
     end)}
  end

  @impl true
  def handle_event("validate", %{"plot" => plot_params}, socket) do
    changeset = Plots.change_plot(socket.assigns.plot, plot_params)

    notify_parent({:filter, plot_params})

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"plot" => plot_params}, socket) do
    save_plot(
      socket,
      socket.assigns.action,
      Map.put(plot_params, "user_id", socket.assigns.user_id)
    )
  end

  defp save_plot(socket, :edit, plot_params) do
    case Plots.update_plot(socket.assigns.plot, plot_params) do
      {:ok, plot} ->
        notify_parent({:saved, plot})

        {:noreply,
         socket
         |> put_flash(:info, "Plot updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_plot(socket, :new, plot_params) do
    dbg(plot_params)

    case Plots.create_plot(plot_params) do
      {:ok, plot} ->
        notify_parent({:saved, plot})

        {:noreply,
         socket
         |> put_flash(:info, "Plot created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
