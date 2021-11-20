# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Guest, type: :model do
  context 'associations' do
    it { is_expected.to have_many(:reservations) }
  end

  context 'validation' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to_not allow_value('blah').for(:email) }
    it { is_expected.to allow_value('a@b.com').for(:email) }
  end
end
