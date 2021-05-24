import {Map, Marker, Popup} from 'maplibre-gl'

class MapComponent extends HTMLElement {
  createMarker(el) {
    const lat = el.getAttribute('lat')
    const lng = el.getAttribute('lng')
    const name = el.getAttribute('name')
    const showTemplate = show => `<li>${show}</li>`
    
    const shows = el.getAttribute('shows')
                    .split('||')
                    .map(showTemplate).join("")

    const popupHTML = `
      <div class="font-bold pb-1">${name}</div>
      <ul class="shows space-y-1">${shows}</ul>
    `

    const popup = new Popup({closeButton: false}).setHTML(popupHTML)
    
    new Marker()
        .setLngLat([lng, lat])
        .setPopup(popup)
        .addTo(this.map);
  }

  createMarkers() {
    const markerEls = this.querySelectorAll('x-map-marker')
    markerEls.forEach(this.createMarker.bind(this))
  }
  
  connectedCallback() {
    const mapElement = document.createElement('div');
    mapElement.id = 'map'
    mapElement.classList.add('absolute')
    mapElement.classList.add('w-full')
    mapElement.classList.add('h-full')

    this.appendChild(mapElement)

    this.map = new Map({
      container: 'map',
      style: window.mapStylePath,
      center: [-90.0910109, 29.9708579],
      zoom: 12
    });
    this.createMarkers()
  }
}

window.customElements.define('x-map', MapComponent);
