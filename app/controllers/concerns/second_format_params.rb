# frozen_string_literal: true

# To handle second format params
module SecondFormatParams
  private

  def second_format_params
    permitted_params.merge(guest: guest_params, reservation_code: permitted_params[:code])
                    .merge(permitted_params[:guest_details])
                    .except(:guest_email, :guest_first_name, :guest_last_name,
                            :guest_phone_numbers, :guest_details)
                    .permit!
  end

  def permitted_params
    params.require(:reservation).permit(:code, :start_date, :end_date, :status_type, :nights,
                                        :expected_payout_amount, :guest_email, :guest_first_name,
                                        :guest_last_name, :listing_security_price_accurate,
                                        :host_currency, :number_of_guests, :total_paid_amount_accurate,
                                        guest_phone_numbers: [],
                                        guest_details: %i[localized_description number_of_adults
                                                          number_of_children number_of_infants])
  end

  def guest_params
    {
      first_name: permitted_params[:guest_first_name],
      last_name: permitted_params[:guest_last_name],
      email: permitted_params[:guest_email],
      phone: permitted_params[:guest_phone_numbers].join(', ')
    }
  end

  def second_format
    param! :reservation, Hash do |data|
      data.param! :code, String, required: true, blank: false
      data.param! :status_type, String, required: true, blank: false, in: Reservation.statuses.keys
      data.param! :start_date, String, required: true, blank: false
      data.param! :end_date, String, required: true, blank: false
      %w[details_param details_partial_param guest_param price_param].each do |method_name|
        send("second_format_#{method_name}", data)
      end
    end
  end

  def second_format_details_param(data)
    data.param! :guest_details, Hash, required: true, blank: false do |guest|
      guest.param! :localized_description, String, required: true, blank: false
      guest.param! :number_of_adults, Integer, required: true, blank: false
      guest.param! :number_of_children, Integer, required: true, blank: false
      guest.param! :number_of_infants, Integer, required: true, blank: false
    end
  end

  def second_format_details_partial_param(data)
    data.param! :nights, Integer, required: true, blank: false
    data.param! :number_of_guests, Integer, required: true, blank: false
  end

  def second_format_guest_param(data)
    data.param! :guest_first_name, String, required: true, blank: false
    data.param! :guest_last_name, String
    data.param! :guest_email, String, required: true, blank: false
    data.param! :guest_phone_numbers, Array, required: true do |arr, index|
      arr.param! index, String, required: true, blank: false, format: GeneralConst::PHONE_REGEX,
                                message: I18n.t('err.param.invalid_phone')
    end
  end

  def second_format_price_param(data)
    data.param! :host_currency, String, required: true, blank: false,
                                        in: Reservation::SUPPORTED_CURRENCIES
    data.param! :expected_payout_amount, Float, precision: 2, required: true, blank: false
    data.param! :listing_security_price_accurate, Float, precision: 2, required: true, blank: false
    data.param! :total_paid_amount_accurate, Float, precision: 2, required: true, blank: false
  end
end
