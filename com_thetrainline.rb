# frozen_string_literal: true

require "httparty"
require "json"
require "date"
require "uri"
Dir[File.join(__dir__, "services", "*.rb")].each { |file| require file }

class ComThetrainline
  BASE_URL = "https://www.thetrainline.com"

  class << self
    def find(from, to, departure_at)
      departure_code = fetch_location(from)
      destination_code = fetch_location(to)
      response = JourneysFetcherService.fetch_journeys(departure_code, destination_code, departure_at)
      JourneysParserService.format_data(response)
    rescue Errors::LocationError, Errors::JourneyError, Errors::JourneyParsingError => e
      {message: e.message, errors: e.errors}
    rescue => e
      {message: "Unexpected error, please try again later", errors: [e.message]}
    end

    private

    def fetch_location(location)
      LocationFetcherService.fetch_location_code(location)
    end
  end
end

ComThetrainline.find("Berlin Hbf", "Warszawa-Centralna", "#<DateTime: 2025-03-12T14:00:00+00:00 ((2456774j,22140s,0n),+0s,2299161j)>")
