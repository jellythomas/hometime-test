# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let(:guest) { create(:guest) }
  let!(:reservation) { create(:reservation, guest: guest) }
  context 'associations' do
    it { is_expected.to belong_to(:guest) }
  end

  context 'validation' do
    it { is_expected.to validate_presence_of(:reservation_code) }
    it { is_expected.to validate_uniqueness_of(:reservation_code) }
    it { is_expected.to_not allow_value('aaa12345678').for(:reservation_code) }
    it { is_expected.to_not allow_value('AAA1234567890').for(:reservation_code) }
    it { is_expected.to_not allow_value('AAA1234567A').for(:reservation_code) }
    it { is_expected.to allow_value('AAA12345678').for(:reservation_code) }
  end
end
