# frozen_string_literal: true

module Exceptions
  class InvalidDateFormat < StandardError
    def initialize(field = nil)
      @field = field
    end

    def message
      I18n.t 'err.invalid_date_format', field: @field
    end
  end

  class EndDateLessThanStartDate < StandardError
    def message
      I18n.t 'err.end_date_less_than_start_date'
    end
  end
end
