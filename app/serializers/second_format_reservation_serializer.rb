# frozen_string_literal: true

class SecondFormatReservationSerializer
  include FastJsonapi::ObjectSerializer
  set_type :reservation

  attributes :code, :start_date, :end_date, :nights, :expected_payout_amount, :listing_security_price_accurate,
             :host_currency, :number_of_guests, :status_type, :total_paid_amount_accurate

  attributes :guest_email do |object|
    object.guest.email
  end

  attributes :guest_first_name do |object|
    object.guest.first_name
  end

  attributes :guest_last_name do |object|
    object.guest.last_name
  end

  attribute :guest_phone_numbers do |object|
    object.guest.phone.split(', ')
  end

  attribute :guest_details do |object|
    object.slice(:localized_description, :number_of_adults, :number_of_children, :number_of_infants)
  end
end
