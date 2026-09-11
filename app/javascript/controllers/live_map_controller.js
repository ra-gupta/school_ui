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
    if (v.stops.length > 1) {
      L.polyline(v.stops.map(s => [s.lat, s.lng]), { color: "#4f46e5", weight: 2, dashArray: "6 6", opacity: 0.5 }).addTo(this.map)
    }

    bus.trail = L.polyline(v.trail.map(f => [f.lat, f.lng]), { color: "#2a78d6", weight: 3, opacity: 0.7 }).addTo(this.map)

    if (bus.position) {
      bus.marker = L.marker(bus.position, { icon: this.icon(v.heading), zIndexOffset: 1000 })
                    .bindTooltip(v.label, { permanent: true, direction: "top", offset: [0, -14], className: "bus-label" })
                    .addTo(this.map)
    }

    bus.subscription = this.cable.subscriptions.create(
      { channel: "VehicleChannel", vehicle_id: v.id },
      { received: fix => this.onFix(bus, fix) }
    )

    this.buses.set(v.id, bus)
    this.render(bus)
  }

  icon(heading) {
    // An arrow reads direction at a glance; a bus glyph does not rotate well.
    return L.divIcon({
      className: "bus-marker",
      html: `<div class="bus-marker__ring"><svg viewBox="0 0 24 24" style="transform: rotate(${heading || 0}deg)">
               <path d="M12 3 L19 20 L12 16 L5 20 Z" fill="currentColor"/></svg></div>`,
      iconSize: [32, 32], iconAnchor: [16, 16]
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
    if (this.followValue && bus?.position) this.map.setView(bus.position, Math.max(this.map.getZoom(), 15), { animate: true })
  }

  fitAll() {
    const points = [...this.buses.values()].flatMap(b => [b.position, ...b.stops.map(s => L.latLng(s.lat, s.lng))]).filter(Boolean)
    if (points.length) this.map.fitBounds(L.latLngBounds(points).pad(0.15))
    else this.map.setView([20.5937, 78.9629], 5)
  }
}
