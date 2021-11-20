# frozen_string_literal: true

class Guest < ApplicationRecord
  include GuestAlias
  has_many :reservations, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: GeneralConst::EMAIL_REGEX }
end
