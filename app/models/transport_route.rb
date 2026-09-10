class TransportRoute < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :vehicle, optional: true
  has_many :route_stops, -> { order(:position) }, dependent: :destroy, inverse_of: :transport_route
  has_many :transport_assignments, dependent: :destroy

  validates :name, presence: true

  manage module_key: "transport", search: %w[name start_point end_point], order: { name: :asc },
         columns: [:name, :start_point, :end_point, { name: :vehicle, type: :belongs_to },
                   { name: :fare, type: :money, align: :right }],
         fields: [{ name: :name, required: true }, :start_point, :end_point,
                  { name: :vehicle, type: :belongs_to }, { name: :fare, type: :money }]
end
