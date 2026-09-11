module Api
  module V1
    # The parent app's view of the bus: only the vehicle(s) their child rides,
    # with stops and the recent trail, so the map draws its first frame before
    # subscribing to VehicleChannel for live fixes.
    class BusController < BaseController
      def show
        students = current_user.student ? [ current_user.student ] : current_user.guardian&.students.to_a
        routes = TransportRoute.joins(:transport_assignments)
                               .where(transport_assignments: { student_id: students.map(&:id) })
                               .includes(:vehicle, :route_stops).distinct

        render json: routes.filter_map { |route|
          vehicle = route.vehicle or next
          fixes = vehicle.vehicle_locations.recent.to_a
          { vehicle_id: vehicle.id, label: vehicle.registration_no, route: route.name,
            driver: vehicle.driver&.name,
            position: fixes.last&.as_fix,
            stops: route.route_stops.map { { name: it.name, lat: it.latitude&.to_f, lng: it.longitude&.to_f,
                                             pickup_at: it.pickup_at&.strftime("%H:%M") } },
            trail: fixes.last(120).map { { lat: it.latitude.to_f, lng: it.longitude.to_f } },
            channel: { name: "VehicleChannel", vehicle_id: vehicle.id } }
        }
      end
    end
  end
end
