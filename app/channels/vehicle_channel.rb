# One stream per vehicle. Who may watch it is decided here, at subscription,
# not in the client: staff with transport.read see the fleet; a family sees
# only the bus their child rides. Same rule as chat.
class VehicleChannel < ApplicationCable::Channel
  def subscribed
    vehicle = Vehicle.unscoped.find_by(id: params[:vehicle_id], school_id: current_user.school_id)
    return reject unless vehicle && may_watch?(vehicle)

    stream_for vehicle
  end

  private

  def may_watch?(vehicle)
    return true if current_user.can?("transport.read")

    riders = Student.unscoped.where(id: current_user.guardian&.students&.ids.to_a + [ current_user.student&.id ].compact)
    TransportAssignment.unscoped
                       .where(student_id: riders.select(:id))
                       .where(transport_route_id: TransportRoute.unscoped.where(vehicle_id: vehicle.id).select(:id))
                       .exists?
  end
end
