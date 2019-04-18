require 'base32/crockford'
require 'base64'
require 'digest'

class ApiToken < ApplicationRecord
  include Concerns::Tokenable
end
