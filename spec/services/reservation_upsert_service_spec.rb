# frozen_string_literal: true

require 'rails_helper'
require 'exceptions'

RSpec.describe ReservationUpsertService, type: :service do
  let(:guest) { create(:guest) }
  let(:first_format_params) do
    {
      "reservation_code": 'YYY12345678',
      "start_date": '2021-04-14',
      "end_date": '2021-04-18',
      "nights": 4,
      "guests": 4,
      "adults": 2,
      "children": 2,
      "infants": 0,
      "status": 'accepted',
      "currency": 'AUD',
      "payout_price": '4200.0',
      "security_price": '500.0',
      "total_price": '4700.0'
    }.with_indifferent_access
  end
  let(:updated_first_format_params) do
    {
      "reservation_code": 'YYY12345678',
      "start_date": '2021-04-18',
      "end_date": '2021-04-25',
      "nights": 5,
      "guests": 5,
      "adults": 4,
      "children": 1,
      "infants": 0,
      "status": 'accepted',
      "currency": 'USD',
      "payout_price": '420.0',
      "security_price": '50.0',
      "total_price": '470.0'
    }.with_indifferent_access
  end

  let(:second_format_params) do
    {
      "code": 'XXX12345678',
      "start_date": '2021-03-12',
      "end_date": '2021-03-16',
      "expected_payout_amount": '3800.0',
      "localized_description": '4 guests',
      "number_of_adults": 2,
      "number_of_children": 2,
      "number_of_infants": 0,
      "listing_security_price_accurate": '500.0',
      "host_currency": 'AUD',
      "nights": 4,
      "number_of_guests": 4,
      "status_type": 'accepted',
      "total_paid_amount_accurate": '4300.0'
    }.with_indifferent_access
  end

  subject { described_class.call(init_reservation, params) }

  describe '.call' do
    context 'reservation with first_format params' do
      context 'create a new one' do
        let(:init_reservation) do
          guest.reservations.find_or_initialize_by(reservation_code: first_format_params[:reservation_code])
        end
        let(:params) { first_format_params }

        it 'reservation is not exist yet' do
          expect(init_reservation.persisted?).to eq false
        end

        it 'reservation create a new reservation' do
          subject
          expect(Reservation.count).to eq 1
        end

        it 'contain a correct data' do
          subject

          expected = Reservation.last.as_json.except('id', 'created_at', 'updated_at', 'guest_id',
                                                     'localized_description').values

          expect(expected).to match_array params.values
        end
      end

      context 'update exist data' do
        let!(:reservation) { create(:reservation, first_format_params.merge(guest: guest)) }
        let(:init_reservation) do
          guest.reservations.find_or_initialize_by(reservation_code: first_format_params[:reservation_code])
        end
        let(:params) { updated_first_format_params }

        it 'reservation is not exist yet' do
          expect(init_reservation.persisted?).to eq true
        end

        it 'reservation create a new reservation' do
          subject
          expect(Reservation.count).to eq 1
        end

        it 'contain a correct data' do
          subject

          expected = Reservation.last.as_json.except('id', 'created_at', 'updated_at', 'guest_id',
                                                     'localized_description').values

          expect(expected).to match_array params.values
        end
      end
    end

    context 'reservation with second_format params' do
      context 'create a new one' do
        let(:init_reservation) do
          guest.reservations.find_or_initialize_by(reservation_code: second_format_params[:code])
        end
        let(:params) { second_format_params }

        it 'reservation is not exist yet' do
          expect(init_reservation.persisted?).to eq false
        end

        it 'reservation create a new reservation' do
          subject
          expect(Reservation.count).to eq 1
        end

        it 'contain a correct data' do
          subject

          expected = Reservation.last.as_json.except('id', 'created_at', 'updated_at',
                                                     'guest_id').values

          expect(expected).to match_array params.values
        end
      end

      context 'update exist data' do
        let!(:reservation) do
          first_format_params[:reservation_code] = second_format_params[:code]
          create(:reservation, first_format_params.merge(guest: guest))
        end
        let(:init_reservation) do
          guest.reservations.find_or_initialize_by(reservation_code: second_format_params[:code])
        end
        let(:params) { second_format_params }

        it 'reservation is not exist yet' do
          expect(init_reservation.persisted?).to eq true
        end

        it 'reservation create a new reservation' do
          subject
          expect(Reservation.count).to eq 1
        end

        it 'contain a correct data' do
          subject

          expected = Reservation.last.as_json.except('id', 'created_at', 'updated_at',
                                                     'guest_id').values

          expect(expected).to match_array params.values
        end
      end
    end

    context 'invalid params' do
      let(:init_reservation) do
        guest.reservations.find_or_initialize_by(reservation_code: first_format_params[:reservation_code])
      end
      let(:params) { first_format_params }

      context 'invalid start_date format' do
        %w[21-03-2021 21/03/2021 2021/03/21].each do |value|
          context "##{value} start_date" do
            it 'raise an error' do
              params[:start_date] = value
              expect { subject }.to raise_error Exceptions::InvalidDateFormat
            end
          end
        end
      end

      context 'invalid end_date format' do
        %w[21-03-2021 21/03/2021 2021/03/21].each do |value|
          context "##{value} end_date" do
            it 'raise an error' do
              params[:end_date] = value
              expect { subject }.to raise_error Exceptions::InvalidDateFormat
            end
          end
        end
      end

      context 'end_date less than start_date' do
        it 'raise an error' do
          params[:end_date] = '2021-03-20'
          expect { subject }.to raise_error Exceptions::EndDateLessThanStartDate
        end
      end
    end
  end
end
