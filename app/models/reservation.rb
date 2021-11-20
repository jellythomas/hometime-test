# frozen_string_literal: true

class Reservation < ApplicationRecord
  include ReservationAlias
  belongs_to :guest

  SUPPORTED_CURRENCIES = %w[AUD USD].freeze

  enum status: {
    pending: 1,
    accepted: 2,
    rejected: 3
  }

  validates :reservation_code, presence: true, uniqueness: true,
                               format: { with: GeneralConst::RESERVATION_CODE_REGEX }
end
