// import "../css/app.scss"
import "phoenix_html"
import {LiveSocket} from "phoenix_live_view"
import {Socket} from "phoenix"
import './components/map'

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

const liveSocket = new LiveSocket("/live", Socket, {
  params: {
    _csrf_token: csrfToken
  },
})

liveSocket.connect()

window.liveSocket = liveSocket
