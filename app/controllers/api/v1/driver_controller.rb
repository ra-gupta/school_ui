module Api
  module V1
    # The driver app posts a fix every few seconds; parents read the trail.
    class DriverController < BaseController
      def location
        vehicle = Vehicle.find_by!(driver_id: current_user.staff&.id)
        fix = vehicle.vehicle_locations.create!(
          params.expect(location: [:latitude, :longitude, :speed, :heading])
                .merge(recorded_at: params.dig(:location, :recorded_at) || Time.current)
        )
        render json: { id: fix.id, recorded_at: fix.recorded_at }, status: :created
      end
    end
  end
end
