namespace :transport do
  desc "Drive a vehicle along its route so the live map can be watched without the driver app. " \
       "VEHICLE=<id> (default: first with stops) SECONDS=<duration, default 180> EVERY=<seconds between fixes, default 2>"
  task simulate: :environment do
    every    = ENV.fetch("EVERY", 2).to_f
    seconds  = ENV.fetch("SECONDS", 180).to_i
    vehicle  = Vehicle.unscoped.find_by(id: ENV["VEHICLE"]) ||
               Vehicle.unscoped.joins(transport_routes: :route_stops).where.not(route_stops: { latitude: nil }).first
    abort "No vehicle with a route that has stop coordinates. Run db:seed first." unless vehicle

    Current.school = vehicle.school
    stops = vehicle.transport_routes.flat_map { it.route_stops.order(:position).to_a }.select { it.latitude && it.longitude }
    abort "Vehicle #{vehicle.registration_no} has no stops with coordinates." if stops.size < 2

    # Out along the stops and back, so a long run does not sail off the map.
    path = (stops + stops.reverse[1..]).map { [ it.latitude.to_f, it.longitude.to_f ] }
    fixes = (seconds / every).to_i
    per_leg = [ fixes / (path.size - 1), 1 ].max

    puts "Simulating #{vehicle.registration_no} over #{stops.size} stops: #{fixes} fixes, one every #{every}s. Ctrl-C to stop."

    path.each_cons(2) do |(lat1, lng1), (lat2, lng2)|
      heading = (Math.atan2(lng2 - lng1, lat2 - lat1) * 180 / Math::PI).round % 360
      per_leg.times do |i|
        t = (i + 1).to_f / per_leg
        # A little wobble, so the trail looks driven rather than drawn.
        lat = lat1 + (lat2 - lat1) * t + rand(-0.00005..0.00005)
        lng = lng1 + (lng2 - lng1) * t + rand(-0.00005..0.00005)
        vehicle.vehicle_locations.create!(latitude: lat, longitude: lng, heading:,
                                          speed: rand(18..42), recorded_at: Time.current)
        print "."
        sleep every
      end
    end
    puts "\ndone"
  end

  desc "Thin old GPS fixes: keep one per minute after a week, drop everything older than a month"
  task prune_locations: :environment do
    older = VehicleLocation.unscoped.where(recorded_at: ...30.days.ago).delete_all
    # For the week-to-month window, keep the first fix of each minute per vehicle.
    thinned = VehicleLocation.unscoped.where(recorded_at: 30.days.ago...7.days.ago)
      .where.not(id: VehicleLocation.unscoped.where(recorded_at: 30.days.ago...7.days.ago)
                                     .select("DISTINCT ON (vehicle_id, date_trunc('minute', recorded_at)) id")
                                     .order(Arel.sql("vehicle_id, date_trunc('minute', recorded_at), recorded_at")))
      .delete_all
    puts "dropped #{older} old fixes, thinned #{thinned}"
  end
end
