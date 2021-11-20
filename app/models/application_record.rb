# frozen_string_literal: true

require './lib/regex_constants'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
