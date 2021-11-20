# frozen_string_literal: true

class ReservationUpsertService
  include DateHelper
  attr_reader :params, :reservation

  def initialize(reservation, params)
    @params = params
    @reservation = reservation
  end

  def self.call(reservation, params)
    new(reservation, params).call
  end

  def call
    ActiveRecord::Base.transaction do
      validate?
      processing_upsert
    end
  end

  private

  def validate?
    params.slice(:start_date, :end_date).each do |(key, value)|
      raise Exceptions::InvalidDateFormat, key unless DateHelper.valid_date?(value)
    end
    raise Exceptions::EndDateLessThanStartDate if end_date_less_than_start_date?
  end

  def end_date_less_than_start_date?
    params[:end_date] <= params[:start_date]
  end

  def processing_upsert
    reservation.assign_attributes params.except(:guest)
    reservation.save!

    reservation
  end
end
