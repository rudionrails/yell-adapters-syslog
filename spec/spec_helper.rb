$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'yell-adapters-syslog'

require 'rspec/core'
require 'rspec/expectations'
require 'rr'

RSpec.configure do |config|
  config.mock_framework = :rr

end

