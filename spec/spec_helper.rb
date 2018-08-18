require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'

require File.expand_path('../api.rb', __dir__)

module RSpecMixin
  include Rack::Test::Methods
  def app
    SurveyAPI
  end
end

RSpec.configure do |c|
  c.include RSpecMixin
end
