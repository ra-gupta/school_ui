require "net/http"

module Routing
  # Road-snapped routing through OpenStreetMap data. No key, no billing account.
  #
  # The public demo server is fine for development and a small school. It is
  # not for production — it is rate-limited and offers no uptime — so set
  # ROUTING_URL to a self-hosted OSRM (or a paid provider that speaks the same
  # shape) before going live. Swapping to Google Directions is one class with
  # the same #route signature.
  class Osrm
    class Unavailable < StandardError; end

    Result = Data.define(:points, :distance_m, :duration_s)

    def initialize(base_url: AppConfig[:routing_url]) = @base = base_url.to_s.chomp("/")

    # points: [[lat, lng], ...] in visiting order. Returns the road path
    # through them, also as [lat, lng] pairs.
    def route(points)
      return Result.new(points: [], distance_m: 0, duration_s: 0) if points.size < 2

      coords = points.map { |lat, lng| "#{lng},#{lat}" }.join(";")   # OSRM is lng,lat
      uri = URI("#{@base}/route/v1/driving/#{coords}?overview=full&geometries=geojson")
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 10) do |http|
        http.get(uri.request_uri, { "User-Agent" => "school-erp/1.0" })
      end
      raise Unavailable, "router returned #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      parse(JSON.parse(response.body))
    rescue Timeout::Error, SocketError, Errno::ECONNREFUSED => e
      raise Unavailable, e.message
    end

    def parse(json)
      route = json.fetch("routes", []).first or raise Unavailable, json["message"] || "no route"
      Result.new(
        points: route.dig("geometry", "coordinates").map { |lng, lat| [ lat, lng ] },
        distance_m: route["distance"].round,
        duration_s: route["duration"].round
      )
    end
  end
end
