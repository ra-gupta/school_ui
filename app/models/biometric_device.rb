class BiometricDevice < ApplicationRecord
  include Tenanted, Manageable
  has_many :biometric_punches, dependent: :destroy
  validates :serial_number, presence: true, uniqueness: true
  scope :active, -> { where(active: true) }

  manage module_key: "biometrics", search: %w[serial_number name location], order: { name: :asc },
         columns: [ :name, :serial_number, :ip_address, :location,
                   { name: :last_seen_at, type: :datetime }, { name: :active, type: :boolean } ],
         fields: [ { name: :name, required: true }, { name: :serial_number, required: true },
                  :ip_address, :location, { name: :active, type: :boolean } ]
end
