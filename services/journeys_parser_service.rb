require_relative "../errors/journey_parsing_error"

class JourneysParserService
  class << self
    COMFORT_CLASSES = {
      "standard" => 1,
      "first" => 2,
      "business" => 3,
      "premium" => 4,
      "sleeper" => 5,
      "coach" => 0
    }.freeze

    def format_data(response)
      response.dig("data", "journeySearch", "journeys")&.map do |journey|
        {
          departure_at: DateTime.parse(journey.last["departAt"]),
          arrival_at: DateTime.parse(journey.last["arriveAt"]),
          duration_in_minutes: parse_duration(journey.last["duration"]),
          changeovers: journey.last["legs"].count - 1,
          service_agencies: extract_service_agencies(response, journey.last["legs"]),
          products: extract_products(response, journey.last["legs"]),
          departure_station: extract_station(response, journey.last["legs"].first, "departureLocation"),
          destination_station: extract_station(response, journey.last["legs"].last, "arrivalLocation"),
          fares: extract_fares(response, journey.last["sections"])
        }
      end
    rescue => e
      raise JourneyParsingError.new("Error processing journey data.", e.message)
    end

    private

    def parse_duration(duration)
      hours = duration[/\d+(?=H)/].to_i
      minutes = duration[/\d+(?=M)/].to_i
      (hours * 60) + minutes
    end

    def extract_service_agencies(response, legs)
      legs.map { |leg| response.dig("data", "carriers", response.dig("data", "journeySearch", "legs", leg, "carrier"), "name") }.compact
    end

    def extract_products(response, legs)
      legs.map { |leg| response.dig("data", "transportModes", response.dig("data", "journeySearch", "legs", leg, "transportMode"), "mode") }.compact
    end

    def extract_station(response, leg, type)
      response.dig("data", "locations", response.dig("data", "journeySearch", "legs", leg, type), "name")
    end

    def extract_fares(response, sections)
      return [] if sections.empty?

      sections.flat_map do |section|
        response.dig("data", "journeySearch", "sections", section, "alternatives")&.map do |alternative|
          fare_data = response.dig("data", "journeySearch", "alternatives", alternative)
          fare_leg = response.dig("data", "journeySearch", "fares", fare_data.dig("fares", 0), "fareLegs", 0)

          {
            price_in_cents: (fare_data.dig("price", "amount") * 100).round,
            currency_code: fare_data.dig("price", "currencyCode"),
            name: fare_leg.dig("comfort", "name"),
            comfort_class: COMFORT_CLASSES[fare_leg.dig("travelClass", "name")&.downcase]
          }
        end
      end.compact
    end
  end
end
