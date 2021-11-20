# frozen_string_literal: true

class FirstFormatReservationSerializer
  include FastJsonapi::ObjectSerializer
  set_type :reservation

  attributes :reservation_code, :start_date, :end_date, :nights, :guests, :adults, :children,
             :infants, :status, :currency, :payout_price, :security_price, :total_price
  attribute :guest do |object|
    object.guest.slice(:email, :first_name, :last_name, :phone)
  end
end
