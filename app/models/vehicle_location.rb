# Written by the driver app, read by the live-tracking screen.
class VehicleLocation < ApplicationRecord
  include Tenanted
  belongs_to :vehicle
  validates :latitude, :longitude, :recorded_at, presence: true
  scope :recent, -> { where(recorded_at: 2.hours.ago..).order(:recorded_at) }

  after_create_commit do
    Notifications::BusApproachingJob.perform_later(id)
    # Pushed to every open map the moment it lands — this is what makes the
    # marker move instead of waiting for a refresh.
    VehicleChannel.broadcast_to(vehicle, as_fix)
  end

  def as_fix
    { id:, lat: latitude.to_f, lng: longitude.to_f, speed: speed&.to_f, heading:,
      at: recorded_at.iso8601(3) }
  end
end
