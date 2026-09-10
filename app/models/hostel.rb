class Hostel < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :warden, class_name: "Staff", optional: true
  has_many :hostel_rooms, dependent: :destroy

  validates :name, presence: true

  manage module_key: "hostel", search: %w[name], order: { name: :asc },
         columns: [:name, :kind, { name: :warden, type: :belongs_to },
                   { name: :capacity, type: :number, align: :right }],
         fields: [{ name: :name, required: true },
                  { name: :kind, type: :select, options: %w[boys girls staff] },
                  { name: :warden, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :capacity, type: :number }, { name: :address, type: :text }]
end
