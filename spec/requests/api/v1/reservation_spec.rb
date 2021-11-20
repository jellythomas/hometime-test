# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reservation API', type: :request do
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
      "guest": {
        "first_name": Faker::Name.first_name,
        "last_name": Faker::Name.last_name,
        "phone": '639123456789',
        "email": 'wayne_woodbridge@bnb.com'
      },
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
      "guest": {
        "first_name": Faker::Name.first_name,
        "last_name": Faker::Name.last_name,
        "phone": '639123456700',
        "email": 'wayne_woodbridge@bnb.com'
      },
      "currency": 'USD',
      "payout_price": '420.0',
      "security_price": '50.0',
      "total_price": '470.0'
    }.with_indifferent_access
  end

  let(:second_format_params) do
    {
      "reservation": {
        "code": 'XXX12345678',
        "start_date": '2021-03-12',
        "end_date": '2021-03-16',
        "expected_payout_amount": '3800.0',
        "guest_details": {
          "localized_description": '4 guests',
          "number_of_adults": 2,
          "number_of_children": 2,
          "number_of_infants": 0
        },
        "guest_email": 'wayne_woodbridge@bnb.com',
        "guest_first_name": 'Wayne',
        "guest_last_name": 'Woodbridge',
        "guest_phone_numbers": %w[
          639123456789
          639123456789
        ],
        "listing_security_price_accurate": '500.0',
        "host_currency": 'AUD',
        "nights": 4,
        "number_of_guests": 4,
        "status_type": 'accepted',
        "total_paid_amount_accurate": '4300.0'
      }
    }.with_indifferent_access
  end

  describe 'POST /api/v1/reservations' do
    context 'first format params' do
      context 'when create new guest' do
        context 'when create new reservation' do
          before  { post '/api/v1/reservations', params: first_format_params }

          it 'get 201 response' do
            expect(response).to have_http_status :created
          end

          it 'contain correct response' do
            expect(json_attributes).to eq first_format_params
          end
        end
      end

      context 'when update existing guest' do
        context 'when create new reservation' do
          let(:guest) { create(:guest, first_format_params[:guest]) }

          before { post '/api/v1/reservations', params: first_format_params }

          it 'get 201 response' do
            expect(response).to have_http_status :created
          end

          it 'contain correct response' do
            expect(json_attributes).to eq first_format_params
          end
        end

        context 'when update existing reservation' do
          let(:guest) { create(:guest, first_format_params[:guest]) }

          before do
            create(:reservation, first_format_params.except(:guest).merge(guest: guest))
            post '/api/v1/reservations', params: updated_first_format_params
          end

          it 'get 204 response' do
            expect(response).to have_http_status :no_content
          end

          it 'update reservation to the new one' do
            expected = Reservation.last.as_json.except('id', 'created_at', 'updated_at', 'guest_id',
                                                       'localized_description').values

            expect(expected).to match_array updated_first_format_params.except(:guest).values
          end
        end
      end

      # start invalid params
      context 'invalid params' do
        context 'nil value' do
          %w[reservation_code start_date end_date nights guests adults children infants payout_price security_price
             total_price].each do |value|
            context "#{value} attribute" do
              before do
                first_format_params[value] = nil
                post '/api/v1/reservations', params: first_format_params
              end

              it 'get 400 response' do
                expect(response).to have_http_status :bad_request
              end

              it 'return an error message' do
                expect(json['errors']).to eq "Parameter #{value} is required"
              end
            end
          end
        end

        context 'not a correct integer' do
          %w[nights guests adults children infants].each do |value|
            context "#{value} attribute" do
              before do
                first_format_params[value] = 'abc'
                post '/api/v1/reservations', params: first_format_params
              end

              it 'get 400 response' do
                expect(response).to have_http_status :bad_request
              end

              it 'return an error message' do
                expect(json['errors']).to eq "'abc' is not a valid Integer"
              end
            end
          end
        end

        context 'not a correct float' do
          %w[total_price payout_price security_price].each do |value|
            context "#{value} attribute" do
              before do
                first_format_params[value] = 'abc'
                post '/api/v1/reservations', params: first_format_params
              end

              it 'get 400 response' do
                expect(response).to have_http_status :bad_request
              end

              it 'return an error message' do
                expect(json['errors']).to eq "'abc' is not a valid Float"
              end
            end
          end
        end

        context 'nil value' do
          %w[first_name email].each do |value|
            context "#{value} attribute" do
              before do
                first_format_params[:guest][value] = nil
                post '/api/v1/reservations', params: first_format_params
              end

              it 'get 400 response' do
                expect(response).to have_http_status :bad_request
              end

              it 'return an error message' do
                expect(json['errors']).to eq "Parameter #{value} is required"
              end
            end
          end
        end

        context 'phone is nil' do
          before do
            first_format_params[:guest][:phone] = nil
            post '/api/v1/reservations', params: first_format_params
          end

          it 'get 400 response' do
            expect(response).to have_http_status :bad_request
          end

          it 'return an error message' do
            expect(json['errors']).to eq I18n.t('err.param.invalid_phone')
          end
        end

        context 'phone is less than 10' do
          before do
            first_format_params[:guest][:phone] = 12_345_678
            post '/api/v1/reservations', params: first_format_params
          end

          it 'get 400 response' do
            expect(response).to have_http_status :bad_request
          end

          it 'return an error message' do
            expect(json['errors']).to eq I18n.t('err.param.invalid_phone')
          end
        end

        context 'phone is greater than 14' do
          before do
            first_format_params[:guest][:phone] = 123_456_789_123_456
            post '/api/v1/reservations', params: first_format_params
          end

          it 'get 400 response' do
            expect(response).to have_http_status :bad_request
          end

          it 'return an error message' do
            expect(json['errors']).to eq I18n.t('err.param.invalid_phone')
          end
        end

        context 'phone has alphabet' do
          before do
            first_format_params[:guest][:phone] = '123456789a'
            post '/api/v1/reservations', params: first_format_params
          end

          it 'get 400 response' do
            expect(response).to have_http_status :bad_request
          end

          it 'return an error message' do
            expect(json['errors']).to eq I18n.t('err.param.invalid_phone')
          end
        end

        context 'when start_date format is invalid' do
          before do
            first_format_params[:start_date] = '12-01-2020'
            post '/api/v1/reservations', params: first_format_params
          end

          it 'get 422 response' do
            expect(response).to have_http_status :unprocessable_entity
          end

          it 'return an error message' do
            expect(json['errors']).to eq I18n.t('err.invalid_date_format', field: 'start_date')
          end
        end

        context 'when end_date format is invalid' do
          before do
            first_format_params[:end_date] = '12-01-2020'
            post '/api/v1/reservations', params: first_format_params
          end

          it 'get 422 response' do
            expect(response).to have_http_status :unprocessable_entity
          end

          it 'return an error message' do
            expect(json['errors']).to eq I18n.t('err.invalid_date_format', field: 'end_date')
          end
        end

        context 'when end_date less than start_date' do
          before do
            first_format_params[:end_date] = '2021-03-14'
            post '/api/v1/reservations', params: first_format_params
          end

          it 'get 422 response' do
            expect(response).to have_http_status :unprocessable_entity
          end

          it 'return an error message' do
            expect(json['errors']).to eq I18n.t('err.end_date_less_than_start_date')
          end
        end

        context 'invalid reservation_code' do
          %w[YYYY2345678 11112345678 YYYYYYYYYYY ABCDEFG].each do |value|
            context "invalid #{value}" do
              before do
                first_format_params[:reservation_code] = value
                post '/api/v1/reservations', params: first_format_params
              end

              it 'get 422 response' do
                expect(response).to have_http_status :unprocessable_entity
              end

              it 'return an error message' do
                expect(json['errors']).to eq 'Validation failed: Reservation code is invalid'
              end
            end
          end
        end

        context 'status not in whitelisted list' do
          before do
            first_format_params[:status] = 'test'
            post '/api/v1/reservations', params: first_format_params
          end

          it 'get 400 response' do
            expect(response).to have_http_status :bad_request
          end

          it 'return an error message' do
            expect(json['errors']).to eq 'Parameter status must be within ["pending", "accepted", "rejected"]'
          end
        end

        context 'currency not in whitelisted list' do
          before do
            first_format_params[:currency] = 'TEST'
            post '/api/v1/reservations', params: first_format_params
          end

          it 'get 400 response' do
            expect(response).to have_http_status :bad_request
          end

          it 'return an error message' do
            expect(json['errors']).to eq 'Parameter currency must be within ["AUD", "USD"]'
          end
        end

        context 'reservation with that code is already exist' do
          let(:guest) { create(:guest, first_format_params[:guest]) }

          before do
            create(:reservation, first_format_params.except(:guest).merge(guest: guest))
            first_format_params[:guest][:email] = 'test@gmail.com'
            post '/api/v1/reservations', params: first_format_params
          end

          it 'get 422 response' do
            expect(response).to have_http_status :unprocessable_entity
          end

          it 'return an error message' do
            expect(json['errors']).to eq 'Validation failed: Reservation code has already been taken'
          end
        end
      end
      # end invalid params
    end

    context 'second format params' do
      context 'when create new guest' do
        context 'when create new reservation' do
          before  { post '/api/v1/reservations', params: second_format_params }

          it 'get 201 response' do
            expect(response).to have_http_status :created
          end

          it 'contain correct response' do
            expect(json_attributes).to eq second_format_params[:reservation]
          end
        end
      end

      context 'when update existing guest' do
        context 'when create new reservation' do
          let(:guest) { create(:guest, first_format_params[:guest]) }

          before { post '/api/v1/reservations', params: second_format_params }

          it 'get 201 response' do
            expect(response).to have_http_status :created
          end

          it 'contain correct response' do
            expect(json_attributes).to eq second_format_params[:reservation]
          end
        end

        context 'when update existing reservation' do
          let(:guest) { create(:guest, updated_first_format_params[:guest]) }

          before do
            updated_first_format_params[:reservation_code] =
              second_format_params[:reservation][:code]
            create(:reservation, updated_first_format_params.except(:guest).merge(guest: guest))
            post '/api/v1/reservations', params: second_format_params
          end

          it 'get 204 response' do
            expect(response).to have_http_status :no_content
          end

          it 'update reservation to the new one' do
            expected = Reservation.last.as_json.except('id', 'created_at', 'updated_at', 'guest_id',
                                                       'localized_description').values
            guest_details = second_format_params[:reservation][:guest_details].slice(:number_of_adults,
                                                                                     :number_of_children, :number_of_infants)
            result = second_format_params[:reservation].merge(guest_details)
                                                       .except(:guest_details, :guest_email,
                                                               :guest_first_name, :guest_last_name, :guest_phone_numbers)
                                                       .values
            expect(expected).to match_array result
          end
        end
      end
    end

    # start invalid params
    context 'invalid params' do
      context 'nil value' do
        %w[code start_date end_date guest_first_name guest_email guest_details
           expected_payout_amount listing_security_price_accurate total_paid_amount_accurate].each do |value|
          context "#{value} attribute" do
            before do
              second_format_params[:reservation][value] = nil
              post '/api/v1/reservations', params: second_format_params
            end

            it 'get 400 response' do
              expect(response).to have_http_status :bad_request
            end

            it 'return an error message' do
              expect(json['errors']).to eq "Parameter #{value} is required"
            end
          end
        end
      end

      context 'not a valid float' do
        %w[expected_payout_amount listing_security_price_accurate
           total_paid_amount_accurate].each do |value|
          context "#{value} attribute" do
            before do
              second_format_params[:reservation][value] = 'abc'
              post '/api/v1/reservations', params: second_format_params
            end

            it 'get 400 response' do
              expect(response).to have_http_status :bad_request
            end

            it 'return an error message' do
              expect(json['errors']).to eq "'abc' is not a valid Float"
            end
          end
        end
      end

      context 'not a valid integer' do
        %w[nights number_of_guests].each do |value|
          context "#{value} attribute" do
            before do
              second_format_params[:reservation][value] = 'abc'
              post '/api/v1/reservations', params: second_format_params
            end

            it 'get 400 response' do
              expect(response).to have_http_status :bad_request
            end

            it 'return an error message' do
              expect(json['errors']).to eq "'abc' is not a valid Integer"
            end
          end
        end
      end

      context 'status_type not in whitelisted list' do
        before do
          second_format_params[:reservation][:status_type] = 'test'
          post '/api/v1/reservations', params: second_format_params
        end

        it 'get 400 response' do
          expect(response).to have_http_status :bad_request
        end

        it 'return an error message' do
          expect(json['errors']).to eq 'Parameter status_type must be within ["pending", "accepted", "rejected"]'
        end
      end

      context 'host_currency not in whitelisted list' do
        before do
          second_format_params[:reservation][:host_currency] = 'TEST'
          post '/api/v1/reservations', params: second_format_params
        end

        it 'get 400 response' do
          expect(response).to have_http_status :bad_request
        end

        it 'return an error message' do
          expect(json['errors']).to eq 'Parameter host_currency must be within ["AUD", "USD"]'
        end
      end

      context 'guest_phone_numbers is an empty array' do
        before do
          second_format_params[:reservation][:guest_phone_numbers] = []
          post '/api/v1/reservations', params: second_format_params
        end

        it 'get 400 response' do
          expect(response).to have_http_status :bad_request
        end

        it 'return an error message' do
          expect(json['errors']).to eq 'Please only input number with lenghts min: 10 and max: 14'
        end
      end

      context 'guest_phone_numbers is nil' do
        before do
          second_format_params[:reservation][:guest_phone_numbers] = nil
          post '/api/v1/reservations', params: second_format_params
        end

        it 'get 400 response' do
          expect(response).to have_http_status :bad_request
        end

        it 'return an error message' do
          expect(json['errors']).to eq "'' is not a valid Array"
        end
      end

      context 'guest_phone_numbers contain invalid phone number format' do
        before do
          second_format_params[:reservation][:guest_phone_numbers] = %w[1234875690 123456789a]
          post '/api/v1/reservations', params: second_format_params
        end

        it 'get 400 response' do
          expect(response).to have_http_status :bad_request
        end

        it 'return an error message' do
          expect(json['errors']).to eq I18n.t('err.param.invalid_phone')
        end
      end

      context 'nil value' do
        %w[localized_description number_of_adults number_of_children
           number_of_infants].each do |value|
          context "#{value} attribute" do
            before do
              second_format_params[:reservation][:guest_details][value] = nil
              post '/api/v1/reservations', params: second_format_params
            end

            it 'get 400 response' do
              expect(response).to have_http_status :bad_request
            end

            it 'return an error message' do
              expect(json['errors']).to eq "Parameter #{value} is required"
            end
          end
        end
      end

      context 'not a valid integer' do
        %w[number_of_adults number_of_children number_of_infants].each do |value|
          context "#{value} attribute" do
            before do
              second_format_params[:reservation][:guest_details][value] = 'abc'
              post '/api/v1/reservations', params: second_format_params
            end

            it 'get 400 response' do
              expect(response).to have_http_status :bad_request
            end

            it 'return an error message' do
              expect(json['errors']).to eq "'abc' is not a valid Integer"
            end
          end
        end
      end

      context 'when start_date format is invalid' do
        before do
          second_format_params[:reservation][:start_date] = '12-01-2020'
          post '/api/v1/reservations', params: second_format_params
        end

        it 'get 422 response' do
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'return an error message' do
          expect(json['errors']).to eq I18n.t('err.invalid_date_format', field: 'start_date')
        end
      end

      context 'when end_date format is invalid' do
        before do
          second_format_params[:reservation][:end_date] = '12-01-2020'
          post '/api/v1/reservations', params: second_format_params
        end

        it 'get 422 response' do
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'return an error message' do
          expect(json['errors']).to eq I18n.t('err.invalid_date_format', field: 'end_date')
        end
      end

      context 'when end_date less than start_date' do
        before do
          second_format_params[:reservation][:end_date] = '2021-02-14'
          post '/api/v1/reservations', params: second_format_params
        end

        it 'get 422 response' do
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'return an error message' do
          expect(json['errors']).to eq I18n.t('err.end_date_less_than_start_date')
        end
      end

      context 'when end_date less than start_date' do
        %w[YYYY2345678 11112345678 YYYYYYYYYYY ABCDEFG].each do |value|
          context "invalid #{value}" do
            before do
              second_format_params[:reservation][:code] = value
              post '/api/v1/reservations', params: second_format_params
            end

            it 'get 422 response' do
              expect(response).to have_http_status :unprocessable_entity
            end

            it 'return an error message' do
              expect(json['errors']).to eq 'Validation failed: Reservation code is invalid'
            end
          end
        end
      end

      context 'reservation with that code is already exist' do
        let(:guest) { create(:guest, first_format_params[:guest]) }

        before do
          create(:reservation, first_format_params.except(:guest).merge(guest: guest))
          second_format_params[:reservation][:guest_email] = 'test@gmail.com'
          second_format_params[:reservation][:code] = first_format_params[:reservation_code]
          post '/api/v1/reservations', params: second_format_params
        end

        it 'get 422 response' do
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'return an error message' do
          expect(json['errors']).to eq 'Validation failed: Reservation code has already been taken'
        end
      end
    end
    # end invalid params
  end
end
