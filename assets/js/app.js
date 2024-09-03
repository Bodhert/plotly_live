// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}
Hooks.Chart = {
	mounted() {
		this.handleEvent("point_added", ({ data }) => {
			console.log(data)
			// Plotly.extendTraces("chart", { x: [[data.x]], y: [[data.y]] }, [0])
			// Plotly.relayout("chart", { xaxis: { range: [data.x - 10, data.x] } })
		})

		this.pushEvent("chart_ready", {}, (reply, ref) => {
			console.log("holi")
			let data = [{
				x: reply.data.map(d => d.x),
				y: reply.data.map(d => d.y),
				type: 'scatter',
				mode: 'lines+markers'
			}]

			let layout = {
				title: 'Real-time Chart',
				xaxis: { title: 'X Axis' },
				yaxis: { title: 'Y Axis' }
			}

			Plotly.newPlot("chart", data, layout)
		})

		console.log("afuera")
		// Data for the plot
		var trace1 = {
			x: [1, 2, 3, 4, 5],
			y: [10, 15, 13, 17, 9],
			mode: 'markers', // scatter plot with markers
			type: 'scatter'  // scatter plot type
		};

		var data = [trace1]; // An array of data traces

		// Layout options for the plot
		var layout = {
			title: 'Simple Scatter Plot',
			xaxis: {
				title: 'X Axis'
			},
			yaxis: {
				title: 'Y Axis'
			}
		};
		Plotly.newPlot('chart', data, layout);
	}
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
// let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } })
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket





