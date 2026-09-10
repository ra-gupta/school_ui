module Notifications
  # Tells the families waiting at a stop that the bus is close.
  #
  # ponytail: straight-line distance and a linear scan over the vehicle's stops.
  # A bus has a handful of stops, so this is cheap; if routes ever grow large,
  # move the proximity test into Postgres with earthdistance or PostGIS.
  class BusApproachingJob < ApplicationJob
    queue_as :default
    RADIUS_METRES = 600
    EARTH_RADIUS_M = 6_371_000

    def perform(vehicle_location_id)
      fix = VehicleLocation.unscoped.find_by(id: vehicle_location_id) or return
      Current.school = fix.school

      stops = RouteStop.unscoped
                       .where(transport_route_id: TransportRoute.unscoped.where(vehicle_id: fix.vehicle_id).select(:id))
                       .where.not(latitude: nil, longitude: nil)

      stops.each do |stop|
        next if distance(fix, stop) > RADIUS_METRES

        riders = Student.unscoped
                        .where(id: TransportAssignment.unscoped.where(route_stop_id: stop.id).select(:student_id))
                        .includes(guardians: :user)
        riders.each do |student|
          Notifier.deliver(event: "bus_approaching", to: student.contact_users, school: fix.school,
                           dedupe_key: "bus:#{stop.id}:#{student.id}:#{Date.current}",
                           values: { stop: stop.name, student: student.name })
        end
      end
    ensure
      Current.school = nil
    end

    private

    def distance(fix, stop)
      lat1, lon1, lat2, lon2 = [ fix.latitude, fix.longitude, stop.latitude, stop.longitude ].map { it.to_f * Math::PI / 180 }
      a = Math.sin((lat2 - lat1) / 2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin((lon2 - lon1) / 2)**2
      2 * EARTH_RADIUS_M * Math.asin(Math.sqrt(a))
    end
  end
end
