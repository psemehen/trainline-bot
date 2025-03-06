require_relative "../errors/location_error"

class LocationFetcherService
  class << self
    def fetch_location_code(location)
      response = process_request(location)
      parse_location_code(response)
    end

    private

    def process_request(location)
      url = build_url("/api/locations-search/v2/search", {searchTerm: location, locale: "en-GB"})
      response = HTTParty.get(url)
      handle_http_error(response, location) unless response.code.between?(200, 299)

      response
    rescue => e
      raise_location_error("Error fetching location: '#{location}'", e)
    end

    def build_url(path, params)
      URI::HTTPS.build(
        host: URI.parse(ComThetrainline::BASE_URL).host,
        path: path,
        query: URI.encode_www_form(params)
      ).to_s
    end

    def parse_location_code(response)
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
  end
end
