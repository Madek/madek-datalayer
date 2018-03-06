require 'base32/crockford'
require 'base64'
require 'digest'

class ApiToken < ActiveRecord::Base
  include Concerns::Tokenable
end
