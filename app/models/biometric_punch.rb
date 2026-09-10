class BiometricPunch < ApplicationRecord
  include Tenanted
  belongs_to :biometric_device, optional: true
  validates :biometric_id, :punched_at, presence: true
  scope :unprocessed, -> { where(processed: false) }
end
