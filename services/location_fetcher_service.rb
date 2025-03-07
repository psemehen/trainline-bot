# frozen_string_literal: true

require_relative "../errors/location_error"
require_relative "../lib/redis_connection"

class LocationFetcherService
  class << self
    def fetch_location_code(location)
      location_code = get_from_cache(location)
      return location_code if location_code

      response = process_request(location)
      location_code = parse_location_code(response, location)
      set_to_cache(location, location_code)
      location_code
    end

    private

    def process_request(location)
      url = build_url("/api/locations-search/v2/search", {searchTerm: location, locale: "en-GB"})
      response = HTTParty.get(url)
      handle_http_error(response, location) unless response.code.between?(200, 299)

      response
    rescue HTTParty::Error, Timeout::Error => e
      raise_location_error("Error fetching location: '#{location}' due to network or timeout issues.", e)
    end

    def build_url(path, params)
      URI::HTTPS.build(
        host: URI.parse(ComThetrainline::BASE_URL).host,
        path: path,
        query: URI.encode_www_form(params)
      ).to_s
    end

    def parse_location_code(response, location)
      location_code = JSON.parse(response.body).dig("searchLocations", 0, "code")
      raise_location_error("Invalid location data received for '#{location}'", response.body) if location_code.to_s.strip.empty?

      location_code
    end

    def handle_http_error(response, location)
      raise_location_error("Failed to fetch location: '#{location}'. HTTP #{response.code}", response.body)
    end

    def raise_location_error(message, *details)
      raise Errors::LocationError.new(message, details.map(&:to_s))
    end

    def get_from_cache(location)
      cached_location = RedisConnection.instance.get("location_code:#{location}")
      cached_location if cached_location
    end

    def set_to_cache(location, location_code)
      RedisConnection.instance.set("location_code:#{location}", location_code, ex: 86_400)
    end
  end
end
