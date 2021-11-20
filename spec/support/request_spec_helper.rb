# frozen_string_literal: true

module RequestSpecHelper
  # Parse JSON response to ruby hash
  def json
    JSON.parse(response.body)
  end

  def json_data
    json['data']
  end

  def json_attributes
    json_data['attributes']
  end
end
