require 'rspec'
require 'guard/compat/test/helper'
require 'guard/redis'

RSpec.configure do |config|
  config.before(:each) do
    allow(Guard::UI).to receive(:info)
  end
end
