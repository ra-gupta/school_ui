class VehicleTrackingController < ApplicationController
  before_action -> { authorize!("transport.read") }

  def show
    @vehicles = Vehicle.includes(:driver, transport_routes: :route_stops).order(:registration_no)
    since = 2.hours.ago
    trails = VehicleLocation.where(vehicle_id: @vehicles.map(&:id), recorded_at: since..)
                            .order(:recorded_at).group_by(&:vehicle_id)

    # Everything the map needs to draw its first frame, before the socket opens.
    @payload = @vehicles.map do |v|
      fixes = trails.fetch(v.id, [])
      last = fixes.last
      {
        id: v.id, label: v.registration_no, driver: v.driver&.name,
        routes: v.transport_routes.map(&:name).join(", "),
        lat: last&.latitude&.to_f, lng: last&.longitude&.to_f,
        heading: last&.heading, speed: last&.speed&.to_f, at: last&.recorded_at&.iso8601(3),
        stops: v.transport_routes.flat_map(&:route_stops).select { it.latitude && it.longitude }
                .map { { name: it.name, lat: it.latitude.to_f, lng: it.longitude.to_f } },
        trail: fixes.last(200).map { { lat: it.latitude.to_f, lng: it.longitude.to_f } }
      }
    end
  end
end
