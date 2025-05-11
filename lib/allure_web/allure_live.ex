defmodule AllureWeb.AllureLive do
  use AllureWeb, :live_view

  def calculator do
    import Computer.Dsl

    computer "Pace" do
      input("duration",
        description: "How long did you run ?",
        type: :number,
        initial: 30
      )

      input("duration_unit",
        description: "Duration Unit",
        type: "text",
        initial: "m"
      )

      input("distance",
        description: "How far did you run ?",
        type: "number",
        initial: 6
      )

      input("distance_unit",
        description: "Distance unit",
        type: "text",
        initial: "km"
      )

      val("normalized_duration",
        depends_on: ~w(duration duration_unit),
        description: "Unitless duration",
        fun: fn %{"duration" => d, "duration_unit" => u} ->
          case u do
            "h" -> d * 60
            "m" -> d
          end
        end
      )

      val("normalized_distance",
        depends_on: ~w(distance distance_unit),
        description: "Unitless distance",
        fun: fn %{"distance" => d, "distance_unit" => u} ->
          case u do
            "km" -> d
            "mi" -> 1.609 * d
          end
        end
      )

      val("pace",
        depends_on: ~w(normalized_duration normalized_distance),
        description: "Pace in minutes per kilometre",
        fun: fn %{"normalized_duration" => ndu, "normalized_distance" => ndi} ->
          ndu / ndi
        end
      )
    end
  end

  def mount(_params, _session, socket) do
    calc = calculator()
    {:ok, cpu_pid} = Computer.make_instance(calc)
    {:ok, socket |> assign(:cpu, cpu_pid) |> assign(:values, calc.values)}
  end

  def handle_event("change", %{"_target" => [key]} = params, socket) do
    value = params[key]

    rvalue =
      if key in ["duration", "distance"] do
        {v, _} = Float.parse(value)
        v
      else
        value
      end

    {:ok, values} = Computer.Instance.handle_input(socket.assigns.cpu, key, rvalue)
    {:noreply, socket |> assign(:values, values)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-2xl font-bold mb-6">Pace Calculator</h1>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="bg-white p-4 rounded shadow">
          <h2 class="text-xl font-semibold mb-4">Inputs</h2>
          <form>
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700">Duration</label>
              <div class="mt-1 flex">
                <input
                  type="number"
                  phx-change="change"
                  name="duration"
                  value={@values["duration"]}
                  class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md"
                />
                <select
                  phx-change="change"
                  name="duration_unit"
                  class="ml-2 shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block sm:text-sm border-gray-300 rounded-md"
                >
                  <option value="m" selected={@values["duration_unit"] == "m"}>Minutes</option>
                  <option value="h" selected={@values["duration_unit"] == "h"}>Hours</option>
                </select>
              </div>
            </div>

            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700">Distance</label>
              <div class="mt-1 flex">
                <input
                  type="number"
                  phx-change="change"
                  name="distance"
                  value={@values["distance"]}
                  class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md"
                />
                <select
                  phx-change="change"
                  name="distance_unit"
                  class="ml-2 shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block sm:text-sm border-gray-300 rounded-md"
                >
                  <option value="km" selected={@values["distance_unit"] == "km"}>Kilometers</option>
                  <option value="mi" selected={@values["distance_unit"] == "mi"}>Miles</option>
                </select>
              </div>
            </div>
          </form>
        </div>

        <div class="bg-white p-4 rounded shadow">
          <h2 class="text-xl font-semibold mb-4">Results</h2>

          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700">Pace</label>
            <div class="mt-1 p-2 bg-gray-100 rounded">
              <span class="text-lg font-medium">
                <%= if is_number(@values["pace"]) do %>
                  {Float.round(@values["pace"], 2)} min/km
                <% else %>
                  --
                <% end %>
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
