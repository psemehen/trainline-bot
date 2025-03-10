# frozen_string_literal: true

require_relative "../errors/validation_error"

module Validators
  class JourneyValidator
    def initialize(from, to, departure_at)
      @from = from
      @to = to
      @departure_at = departure_at
    end

    def validate
      errors = []
      errors << "Missing 'from' location" if blank?(@from)
      errors << "Missing 'to' location" if blank?(@to)
      errors << "Missing 'departure_at' date" if blank?(@departure_at)
      errors << "'departure_at' has an invalid format" unless valid_date_format?(@departure_at)

      raise Errors::ValidationError.new(errors) if errors.any?
    end

    private

    def blank?(value)
      value.nil? || value.strip.empty?
    end

    def valid_date_format?(date_str)
      DateTime.parse(date_str)
    rescue
      false
    end
  end
end
