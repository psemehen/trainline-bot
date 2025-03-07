# frozen_string_literal: true

module Errors
  class JourneyError < StandardError
    attr_reader :errors

    def initialize(message, errors = [])
      super(message)
      @errors = errors
    end
  end
end
