class RouteGeometryJob < ApplicationJob
  queue_as :default
  retry_on Routing::Osrm::Unavailable, wait: 1.minute, attempts: 5

  def perform(transport_route_id)
    route = TransportRoute.unscoped.find_by(id: transport_route_id) or return
    Current.school = route.school
    route.refresh_geometry!
  ensure
    Current.school = nil
  end
end
