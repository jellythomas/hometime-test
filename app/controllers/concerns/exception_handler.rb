# frozen_string_literal: true

require 'exceptions'

module ExceptionHandler
  extend ActiveSupport::Concern
  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      err = I18n.t('err.activerecord.record_not_found', model: e.model)
      json_response({
                      errors: err,
                      status: :not_found
                    }, :not_found)
    end

    rescue_from RailsParam::InvalidParameterError do |err|
      json_response({
                      errors: err.message,
                      status: :bad_request
                    }, :bad_request)
    end

    rescue_from ActiveRecord::RecordInvalid,
                Exceptions::InvalidDateFormat,
                Exceptions::EndDateLessThanStartDate do |err|
      json_response({
                      errors: err.message,
                      status: :unprocessable_entity
                    }, :unprocessable_entity)
    end
  end
end
