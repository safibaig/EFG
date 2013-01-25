if ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov-rcov'

  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start 'rails'

  RSpec.configure do |config|
    config.before(:each) do
      SimpleCov.command_name "RSpec:#{Process.pid.to_s}:#{ENV['TEST_ENV_NUMBER']}"
    end
  end
end
