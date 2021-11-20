# frozen_string_literal: true

module GeneralConst
  PHONE_REGEX = /^[0-9]{10,14}$/.freeze
  EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/.freeze
  RESERVATION_CODE_REGEX = /[A-Z]{3}[0-9]{8}\z/.freeze
  DATE_FORMAT = /\d{4}-\d{2}-\d{2}/.freeze
end
