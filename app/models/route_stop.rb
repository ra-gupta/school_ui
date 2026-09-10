class RouteStop < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :transport_route
  has_many :transport_assignments, dependent: :nullify

  validates :name, presence: true

  manage module_key: "transport", search: %w[name], order: { position: :asc },
         columns: [{ name: :transport_route, type: :belongs_to }, :name,
                   { name: :pickup_at, type: :time }, { name: :drop_at, type: :time },
                   { name: :position, type: :number, align: :right }],
         fields: [{ name: :transport_route, type: :belongs_to, required: true },
                  { name: :name, required: true }, { name: :pickup_at, type: :time },
                  { name: :drop_at, type: :time }, { name: :latitude, type: :money },
                  { name: :longitude, type: :money }, { name: :position, type: :number }]
end
