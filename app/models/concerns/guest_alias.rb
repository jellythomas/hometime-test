# frozen_string_literal: true

module GuestAlias
  extend ActiveSupport::Concern
  GUEST_ALIAS_LIST = {
    email: %w[guest_email],
    first_name: %w[guest_first_name],
    last_name: %w[guest_last_name],
    phone: %w[guest_phone_numbers]
  }.freeze

  included do
    GUEST_ALIAS_LIST.each do |(key, values)|
      values.each { |value| alias_attribute value.to_sym, key.to_sym }
    end
  end
end
