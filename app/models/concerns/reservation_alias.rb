# frozen_string_literal: true

module ReservationAlias
  extend ActiveSupport::Concern
  RESERVATION_ALIAS_LIST = {
    reservation_code: %w[code],
    guests: %w[number_of_guests],
    adults: %w[number_of_adults],
    children: %w[number_of_children],
    infants: %w[number_of_infants],
    status: %w[status_type],
    currency: %w[host_currency],
    payout_price: %w[expected_payout_amount],
    security_price: %w[listing_security_price_accurate],
    total_price: %w[total_paid_amount_accurate]
  }.freeze

  included do
    RESERVATION_ALIAS_LIST.each do |(key, values)|
      values.each { |value| alias_attribute value.to_sym, key.to_sym }
    end
  end
end
