class AddGeometryToTransportRoutes < ActiveRecord::Migration[8.1]
  def change
    # The road-following path through the stops, as [lat, lng] pairs, fetched
    # from the router and cached here so the map never waits on it.
    add_column :transport_routes, :geometry, :jsonb, null: false, default: []
    add_column :transport_routes, :geometry_fetched_at, :datetime
    add_column :transport_routes, :road_distance_m, :integer
  end
end
