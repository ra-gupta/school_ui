require "test_helper"

# No network. Covers the one thing that can silently go wrong: OSRM speaks
# lng,lat and the rest of the app speaks lat,lng.
class Routing::OsrmTest < ActiveSupport::TestCase
  test "turns an OSRM response into lat,lng points with distance" do
    json = { "routes" => [ { "distance" => 1234.6, "duration" => 210.2,
                             "geometry" => { "coordinates" => [ [ 73.85, 18.52 ], [ 73.86, 18.53 ] ] } } ] }

    result = Routing::Osrm.new(base_url: "http://router.test").parse(json)

    assert_equal [ [ 18.52, 73.85 ], [ 18.53, 73.86 ] ], result.points
    assert_equal 1235, result.distance_m
    assert_equal 210, result.duration_s
  end

  test "reports a routing failure rather than returning an empty path" do
    assert_raises(Routing::Osrm::Unavailable) do
      Routing::Osrm.new(base_url: "http://router.test").parse({ "code" => "NoRoute", "message" => "Impossible route." })
    end
  end

  test "asks for nothing with fewer than two points" do
    result = Routing::Osrm.new(base_url: "http://router.test").route([ [ 18.52, 73.85 ] ])
    assert_empty result.points
  end
end
