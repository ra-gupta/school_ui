# Written by the driver app, read by the live-tracking screen.
class VehicleLocation < ApplicationRecord
  include Tenanted
  belongs_to :vehicle
  validates :latitude, :longitude, :recorded_at, presence: true
  scope :recent, -> { where(recorded_at: 2.hours.ago..).order(:recorded_at) }

  after_create_commit { Notifications::BusApproachingJob.perform_later(id) }
end
