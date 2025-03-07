# frozen_string_literal: true

require_relative "../errors/journey_error"

class JourneysFetcherService
  class << self
    def fetch_journeys(departure_code, destination_code, departure_at)
      response = fetch_journey_data(departure_code, destination_code, departure_at)
      parse_journeys(response)
    end

    private

    def fetch_journey_data(departure_code, destination_code, departure_at)
      formatted_departure_at = format_departure_at(departure_at)
      headers = build_headers(departure_code, destination_code, formatted_departure_at)
      body = build_body(departure_code, destination_code, formatted_departure_at)

      process_request(url, headers, body)
    end

    def url
      "#{ComThetrainline::BASE_URL}/api/journey-search/"
    end

    def process_request(url, headers, body)
      response = HTTParty.post(url, headers: headers, body: body)
      handle_http_error(response) unless response.code.between?(200, 299)

      response
    rescue HTTParty::Error, Timeout::Error => e
      raise_journey_error("Error fetching journeys from '#{url}'", e)
    end

    def build_headers(departure_code, destination_code, departure_at)
      {
        "Accept" => "application/json",
        "Accept-Language" => "en-US",
        "Content-Type" => "application/json",
        "Origin" => "https://www.thetrainline.com",
        "Referer" => "https://www.thetrainline.com/book/results?origin=#{departure_code}&destination=#{destination_code}&outwardDate=#{departure_at}&outwardDateType=departAfter",
        "X-Version" => "4.41.30458"
      }
    end

    def build_body(departure_code, destination_code, departure_at)
      {
        passengers: [{id: "pid-0", dateOfBirth: "1992-03-04", cardIds: []}],
        cards: [],
        transitDefinitions: [{
          direction: "outward",
          origin: departure_code,
          destination: destination_code,
          journeyDate: {type: "departAfter", time: departure_at}
        }],
        type: "single",
        maximumJourneys: 10,
        includeRealtime: true,
        transportModes: ["mixed"],
        directSearch: false,
        composition: %w[through interchangeSplit],
        autoApplyCorporateCodes: false
      }.to_json
    end

    def format_departure_at(departure_at)
      DateTime.parse(departure_at).strftime("%Y-%m-%dT%H:%M:%S%:z")
    end

    def parse_journeys(response)
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise_journey_error("Error parsing journey data.", e)
    end

    def handle_http_error(response)
      raise_journey_error("Failed to fetch journeys. HTTP #{response.code}", response.body)
    end

    def raise_journey_error(message, *details)
      raise Errors::JourneyError.new(message, details.map(&:to_s))
    end
  end
end
