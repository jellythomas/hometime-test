# frozen_string_literal: true

require './lib/regex_constants'

module Api
  module V1
    class ReservationsController < ::ApplicationController
      include FirstFormatParams
      include SecondFormatParams

      before_action :validate_request, only: :create

      def create
        response_code = reservation.persisted? ? :no_content : :created
        result = ReservationUpsertService.call(reservation, allowed_params.except(:guest))

        json_response(response_serializer(result, response_code).serialized_json, response_code)
      end

      private

      def guest
        @guest ||= begin
          init_guest = Guest.find_or_initialize_by(email: allowed_params[:guest][:email])
          init_guest.assign_attributes allowed_params[:guest]
          init_guest.save!
          init_guest
        end
      end

      def reservation
        @reservation ||= guest.reservations.find_or_initialize_by(reservation_code: allowed_params[:reservation_code])
      end

      def response_serializer(result, _response_code)
        return ::SecondFormatReservationSerializer.new(result) if wrapped_params?

        ::FirstFormatReservationSerializer.new(result)
      end

      def allowed_params
        wrapped_params? ? second_format_params : first_format_params
      end

      def validate_request
        wrapped_params? ? second_format : first_format
      end

      def wrapped_params?
        params[:reservation].present?
      end
    end
  end
end
