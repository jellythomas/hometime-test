# frozen_string_literal: true

# to handle base format params
module FirstFormatParams
  private

  def first_format_params
    params.permit(:reservation_code, :start_date, :end_date, :status, :nights, :guests, :adults,
                  :children, :infants, :currency, :payout_price, :security_price, :total_price,
                  guest: %i[first_name last_name email phone])
  end

  def first_format
    param! :reservation_code, String, required: true, blank: false
    param! :status, String, required: true, blank: false, in: Reservation.statuses.keys
    param! :start_date, String, required: true, blank: false
    param! :end_date, String, required: true, blank: false
    %w[details_param guest_param price_param].each do |method_name|
      send("first_format_#{method_name}")
    end
  end

  def first_format_details_param
    param! :nights, Integer, required: true, blank: false
    param! :guests, Integer, required: true, blank: false
    param! :adults, Integer, required: true, blank: false
    param! :children, Integer, required: true, blank: false
    param! :infants, Integer, required: true, blank: false
  end

  def first_format_guest_param
    param! :guest, Hash, required: true, blank: false do |guest|
      guest.param! :first_name, String, required: true, blank: false
      guest.param! :last_name, String
      guest.param! :email, String, required: true, blank: false
      guest.param! :phone, String, required: true, blank: false, format: GeneralConst::PHONE_REGEX,
                                   message: I18n.t('err.param.invalid_phone')
    end
  end

  def first_format_price_param
    param! :currency, String, required: true, blank: false, in: Reservation::SUPPORTED_CURRENCIES
    param! :payout_price, Float, required: true, blank: false
    param! :security_price, Float, required: true, blank: false
    param! :total_price, Float, required: true, blank: false
  end
end
