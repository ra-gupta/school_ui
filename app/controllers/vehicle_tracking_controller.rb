class VehicleTrackingController < ApplicationController
  before_action -> { authorize!("transport.read") }

  def show
    @vehicles = Vehicle.includes(:driver, :transport_routes).order(:registration_no)
    @latest = VehicleLocation.where(vehicle_id: @vehicles.map(&:id))
                             .order(:vehicle_id, recorded_at: :desc)
                             .select("DISTINCT ON (vehicle_id) *")
                             .index_by(&:vehicle_id)
  end
end
