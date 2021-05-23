import "../css/app.scss"
import {Socket} from "phoenix"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const socket = new Socket("/socket", {params: {token: csrfToken}})
const channel = socket.channel("map", {})

channel.join().receive("ok", addVenues)
socket.connect()

maplibregl.setRTLTextPlugin('https://cdn.maptiler.com/mapbox-gl-js/plugins/mapbox-gl-rtl-text/v0.1.2/mapbox-gl-rtl-text.js');

var map = new maplibregl.Map({
  container: 'map',
  style: window.mapStylePath,
  center: [-90.0910109, 29.9708579],
  zoom: 12
});

function addVenues(venues) {
  venues.map(addVenue)
}

function addVenue(venue) {
  const coordinates = venue.point?.coordinates

  if (coordinates) {
    new maplibregl.Marker()
       .setLngLat(coordinates)
       .setPopup(venuePopup(venue))
       .addTo(map)
  }
}

function venuePopup({name, shows, web_address}) {
  const linked_name = web_address ? `<a href="${web_address}">${name}</a>` : name
  
  const html = `
    <strong>${linked_name}</strong><br>
    ${shows.map(showHtml).join("<hr>")}
  `
  return new maplibregl.Popup().setHTML(html)
}

function showHtml({name, datetime}) {
  const time = new Date(datetime).toLocaleTimeString()
  
  return `${name}<br>${time}`
}