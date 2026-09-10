class Vehicle < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :driver, class_name: "Staff", optional: true
  has_many :transport_routes, dependent: :nullify
  has_many :vehicle_locations, dependent: :delete_all

  validates :registration_no, presence: true, uniqueness: { scope: :school_id }

  manage module_key: "transport", search: %w[registration_no model], order: { registration_no: :asc },
         columns: [ :registration_no, :model, { name: :driver, type: :belongs_to },
                   { name: :capacity, type: :number, align: :right },
                   { name: :insurance_expires_on, type: :date }, :status ],
         fields: [ { name: :registration_no, required: true }, :model,
                  { name: :driver, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :capacity, type: :number }, :gps_device_id,
                  { name: :insurance_expires_on, type: :date }, { name: :fitness_expires_on, type: :date },
                  { name: :status, type: :select, options: %w[active maintenance retired] } ]

  def name = [ registration_no, model ].compact_blank.join(" · ")
  def last_location = vehicle_locations.order(recorded_at: :desc).first
end
