# frozen_string_literal: true

require "httparty"
require "json"
require "date"
require "uri"
require_relative "validators/journey_validator"
Dir[File.join(__dir__, "services", "*.rb")].each { |file| require file }

class ComThetrainline
  BASE_URL = "https://www.thetrainline.com"

  class << self
    def find(from, to, departure_at)
      validate_input(from, to, departure_at)

      departure_code = fetch_location(from)
      destination_code = fetch_location(to)
      response = JourneysFetcherService.fetch_journeys(departure_code, destination_code, departure_at)
      JourneysParserService.format_data(response)
    rescue Errors::LocationError, Errors::JourneyError, Errors::JourneyParsingError, Errors::ValidationError => e
      {message: e.message, errors: e.errors}
    rescue => e
      {message: "Unexpected error, please try again later", errors: [e.message]}
    end

    private

    def validate_input(from, to, departure_at)
      Validators::JourneyValidator.new(from, to, departure_at).validate
    end

    def fetch_location(location)
      LocationFetcherService.fetch_location_code(location)
    end
  end
end

ComThetrainline.find(ENV["FROM"], ENV["TO"], ENV["DEPARTURE_AT"])
