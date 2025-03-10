module Errors
  class ValidationError < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super("Validation errors.")
    end
  end
end
