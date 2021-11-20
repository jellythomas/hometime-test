# frozen_string_literal: true

FactoryBot.define do
  factory :reservation do
    reservation_code { 'YYY12345678' }
    start_date { Time.zone.today }
    end_date { Time.zone.today + 1.year }
    nights { 4 }
    guests { 4 }
    adults { 2 }
    children { 2 }
    infants { 0 }
    status { Reservation.statuses[:accepted] }
    currency { 'AUD' }
    payout_price { 4200.00 }
    security_price { 500.00 }
    total_price { 4700.00 }
    guest_id {}
  end
end
