class TransportRoute < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :vehicle, optional: true
  has_many :route_stops, -> { order(:position) }, dependent: :destroy, inverse_of: :transport_route
  has_many :transport_assignments, dependent: :destroy

  validates :name, presence: true

  def stop_points = route_stops.select { it.latitude && it.longitude }.map { [ it.latitude.to_f, it.longitude.to_f ] }

  # The road path through the stops, cached. Straight lines between stops are
  # what the map falls back to when this is empty.
  def refresh_geometry!
    result = Routing::Osrm.new.route(stop_points)
    update!(geometry: result.points, road_distance_m: result.distance_m, geometry_fetched_at: Time.current)
  end

  manage module_key: "transport", search: %w[name start_point end_point], order: { name: :asc },
         columns: [ :name, :start_point, :end_point, { name: :vehicle, type: :belongs_to },
                   { name: :fare, type: :money, align: :right } ],
         fields: [ { name: :name, required: true }, :start_point, :end_point,
                  { name: :vehicle, type: :belongs_to }, { name: :fare, type: :money } ]
end
