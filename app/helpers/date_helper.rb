# frozen_string_literal: true

module DateHelper
  def self.valid_date?(date)
    valid_format = date&.match(/\d{4}-\d{2}-\d{2}/)
    parseable = begin
      Date.strptime(date, '%Y-%m-%d')
    rescue StandardError
      false
    end
    valid_format && parseable
  end
end
