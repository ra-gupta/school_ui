import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"
import "leaflet"

// Delivery-app style tracking. Three things make it feel live rather than a
// page that refreshes: fixes arrive over a socket the moment the driver posts
// them, the marker glides from its last position to the new one over the gap
// between fixes instead of jumping, and the ETA and "updated 3s ago" tick on
// their own clock. Everything here is per vehicle; the map holds many.
export default class extends Controller {
  static values = { vehicles: Array, follow: Number }
  static targets = ["map"]

  connect() {
    this.map = L.map(this.mapTarget, { zoomControl: true })
    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19, attribution: "&copy; OpenStreetMap"
    }).addTo(this.map)

    this.cable = createConsumer()
    this.buses = new Map()
    this.vehiclesValue.forEach(v => this.addVehicle(v))
    this.fitAll()

    this.ticker = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.ticker)
    this.buses.forEach(b => { b.subscription?.unsubscribe(); cancelAnimationFrame(b.frame) })
    this.map.remove()
  }

  // ---- setup ---------------------------------------------------------------

  addVehicle(v) {
    const bus = { ...v, marker: null, trail: null, subscription: null, frame: null,
                  position: v.lat != null ? L.latLng(v.lat, v.lng) : null }

    v.stops.forEach(s => {
      L.circleMarker([s.lat, s.lng], { radius: 5, color: "#4f46e5", weight: 2, fillColor: "#fff", fillOpacity: 1 })
       .bindTooltip(s.name).addTo(this.map)
    })
    // The planned route: along the roads when the router has supplied it,
    // straight between stops until then.
    const planned = v.road && v.road.length > 1 ? v.road : v.stops.map(s => [s.lat, s.lng])
    if (planned.length > 1) {
      L.polyline(planned, { color: "#4f46e5", weight: v.road?.length ? 4 : 2, opacity: v.road?.length ? 0.45 : 0.5,
                            dashArray: v.road?.length ? null : "6 6", lineCap: "round", lineJoin: "round" }).addTo(this.map)
    }

    bus.trail = L.polyline(v.trail.map(f => [f.lat, f.lng]), { color: "#2a78d6", weight: 3, opacity: 0.7 }).addTo(this.map)

    if (bus.position) {
      bus.marker = L.marker(bus.position, { icon: this.icon(v.heading), zIndexOffset: 1000 })
                    .bindTooltip(v.label, { permanent: true, direction: "top", offset: [0, -14], className: "bus-label" })
                    .addTo(this.map)
    }

    if (bus.marker) bus.marker.on("click", () => this.showDetail(bus))

    bus.subscription = this.cable.subscriptions.create(
      { channel: "VehicleChannel", vehicle_id: v.id },
      { received: fix => this.onFix(bus, fix) }
    )

    this.buses.set(v.id, bus)
    this.render(bus)
  }

  icon(heading) {
    // The bus stays upright — a rotated bus reads as a crash at 180° — and a
    // pointer on the ring's edge carries the heading instead.
    return L.divIcon({
      className: "bus-marker",
      html: `<div class="bus-marker__wrap">
               <div class="bus-marker__pointer" style="transform: rotate(${heading || 0}deg)"><span></span></div>
               <div class="bus-marker__ring">
                 <svg viewBox="0 0 24 24" fill="currentColor"><path d="M4 16c0 .9.4 1.7 1 2.2V20a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-1h8v1a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-1.8c.6-.5 1-1.3 1-2.2V6c0-3.5-3.6-4-8-4S4 2.5 4 6v10zm3.5 1a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3zm9 0a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3zM6 11V6h12v5H6z"/></svg>
               </div>
             </div>`,
      iconSize: [40, 40], iconAnchor: [20, 20], popupAnchor: [0, -22]
    })
  }

  // ---- live updates --------------------------------------------------------

  onFix(bus, fix) {
    const to = L.latLng(fix.lat, fix.lng)
    const previousAt = bus.at ? new Date(bus.at) : null
    bus.at = fix.at; bus.speed = fix.speed; bus.heading = fix.heading

    if (!bus.marker) {
      bus.marker = L.marker(to, { icon: this.icon(fix.heading), zIndexOffset: 1000 })
                    .bindTooltip(bus.label, { permanent: true, direction: "top", offset: [0, -14], className: "bus-label" })
                    .addTo(this.map)
      bus.marker.on("click", () => this.showDetail(bus))
      bus.position = to
    } else {
      // Glide over the real gap between fixes so the marker arrives just as the
      // next one is due. Capped so a stale gap does not crawl for a minute.
      const gapMs = previousAt ? Math.min(new Date(fix.at) - previousAt, 6000) : 2000
      this.glide(bus, bus.position, to, Math.max(gapMs, 400))
    }

    bus.trail.addLatLng(to)
    if (bus.trail.getLatLngs().length > 400) bus.trail.setLatLngs(bus.trail.getLatLngs().slice(-400))

    this.render(bus)
    if (this.followValue === bus.id) this.map.panTo(to, { animate: true, duration: 0.8 })
    if (bus.detailOpen) this.showDetail(bus)
  }

  // ---- exact location ------------------------------------------------------

  async showDetail(bus) {
    if (!bus.position) return
    bus.detailOpen = true
    const next = this.nextStop(bus)
    const { lat, lng } = bus.position
    const html = (place) => `
      <div class="bus-detail">
        <p class="bus-detail__title">${bus.label}${bus.driver ? " · " + bus.driver : ""}</p>
        <p class="bus-detail__place">${place || "Locating…"}</p>
        <dl>
          <dt>Coordinates</dt><dd><a href="https://www.openstreetmap.org/?mlat=${lat}&mlon=${lng}#map=17/${lat}/${lng}" target="_blank" rel="noopener">${lat.toFixed(5)}, ${lng.toFixed(5)}</a></dd>
          <dt>Speed</dt><dd>${bus.speed != null ? Math.round(bus.speed) + " km/h" : "—"} · heading ${bus.heading ?? "—"}°</dd>
          <dt>Nearest stop</dt><dd>${next ? `${next.name} · ${Math.round(next.distance)} m · ${this.eta(next.distance, bus.speed)}` : "—"}</dd>
          <dt>Updated</dt><dd>${bus.at ? new Date(bus.at).toLocaleTimeString() : "—"}</dd>
        </dl>
      </div>`
    if (!bus.popup) bus.popup = L.popup({ maxWidth: 280, className: "bus-popup", autoPan: false })
    bus.popup.setLatLng(bus.position).setContent(html(bus.place)).openOn(this.map)
    bus.popup.on("remove", () => { bus.detailOpen = false })

    const place = await this.placeName(bus)
    if (bus.detailOpen && place) bus.popup.setContent(html(place))
  }

  // Reverse geocode through OSM's Nominatim, at most once per ~50m of travel:
  // its usage policy is one request a second, and a bus posts more often.
  async placeName(bus) {
    const { lat, lng } = bus.position
    if (bus.placeAt && bus.position.distanceTo(bus.placeAt) < 50) return bus.place
    bus.placeAt = bus.position
    try {
      const r = await fetch(`https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lng}&zoom=17`,
                            { headers: { "Accept": "application/json" } })
      const j = await r.json()
      const a = j.address || {}
      bus.place = [a.road || a.pedestrian || a.neighbourhood, a.suburb || a.village || a.town, a.city || a.county]
                    .filter(Boolean).filter((v, i, arr) => arr.indexOf(v) === i).join(", ") || j.display_name
    } catch { bus.place = bus.place || null }
    return bus.place
  }

  glide(bus, from, to, durationMs) {
    cancelAnimationFrame(bus.frame)
    const started = performance.now()
    const heading = bus.heading
    const step = now => {
      const t = Math.min((now - started) / durationMs, 1)
      const eased = t * (2 - t)                   // ease-out: fast start, settles gently
      const lat = from.lat + (to.lat - from.lat) * eased
      const lng = from.lng + (to.lng - from.lng) * eased
      bus.position = L.latLng(lat, lng)
      bus.marker.setLatLng(bus.position)
      if (t < 1) bus.frame = requestAnimationFrame(step)
    }
    bus.marker.setIcon(this.icon(heading))
    bus.frame = requestAnimationFrame(step)
  }

  // ---- panel ---------------------------------------------------------------

  tick() { this.buses.forEach(b => this.render(b)) }

  render(bus) {
    const card = this.element.querySelector(`[data-vehicle="${bus.id}"]`)
    if (!card) return
    const set = (key, text) => { const el = card.querySelector(`[data-field="${key}"]`); if (el) el.textContent = text }

    if (!bus.position) { set("status", "No signal"); return }
    const ageS = bus.at ? Math.round((Date.now() - new Date(bus.at)) / 1000) : null
    set("status", ageS == null ? "—" : ageS < 5 ? "Live" : ageS < 120 ? `${ageS}s ago` : `${Math.round(ageS / 60)} min ago`)
    set("speed", bus.speed != null ? `${Math.round(bus.speed)} km/h` : "—")

    const next = this.nextStop(bus)
    set("next", next ? next.name : "—")
    set("eta", next ? this.eta(next.distance, bus.speed) : "—")
    card.classList.toggle("is-live", ageS != null && ageS < 30)
  }

  // Nearest stop is "next" — good enough without knowing direction of travel.
  // ponytail: use route order + which stops were already passed if it misleads.
  nextStop(bus) {
    let best = null
    bus.stops.forEach(s => {
      const d = bus.position.distanceTo([s.lat, s.lng])
      if (!best || d < best.distance) best = { ...s, distance: d }
    })
    return best
  }

  eta(metres, speedKmh) {
    const kmh = Math.max(speedKmh || 0, 12)      // a stopped bus still gets an estimate
    const mins = Math.round((metres / 1000) / kmh * 60)
    if (metres < 80) return "Arriving"
    return mins < 1 ? "< 1 min" : `~${mins} min`
  }

  // ---- actions -------------------------------------------------------------

  follow(event) {
    const id = Number(event.currentTarget.dataset.vehicle)
    this.followValue = this.followValue === id ? 0 : id
    this.element.querySelectorAll("[data-action*='follow']").forEach(b => b.classList.toggle("is-active", Number(b.dataset.vehicle) === this.followValue))
    const bus = this.buses.get(id)
    if (this.followValue && bus?.position) {
      this.map.setView(bus.position, Math.max(this.map.getZoom(), 16), { animate: true })
      this.showDetail(bus)
    }
  }

  locate(event) {
    const bus = this.buses.get(Number(event.currentTarget.dataset.vehicle))
    if (!bus?.position) return
    this.map.setView(bus.position, 17, { animate: true })
    this.showDetail(bus)
  }

  fitAll() {
    const points = [...this.buses.values()].flatMap(b => [b.position, ...b.stops.map(s => L.latLng(s.lat, s.lng))]).filter(Boolean)
    if (points.length) this.map.fitBounds(L.latLngBounds(points).pad(0.15))
    else this.map.setView([20.5937, 78.9629], 5)
  }
}
