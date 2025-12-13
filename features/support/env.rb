# Coverage tracking must be started before any application code is loaded
require 'simplecov'
require 'simplecov-lcov'
require 'rspec/expectations'
require 'rspec/mocks'
require 'logger'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
])

SimpleCov.start do
  add_filter '/features/'     # Don't measure test code
  add_filter '/vendor/'       # Don't measure dependencies
  add_filter '/spec/'         # Don't measure specs if you add them later

  # Track these directories
  add_group 'Models', 'lib/deadlist/models'
  add_group 'CLI', 'lib/deadlist/cli'
  add_group 'Core', 'lib/deadlist.rb'
end

World(RSpec::Mocks::ExampleMethods)

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

require_relative '../../lib/deadlist/version'

# Helper to create a logger for testing that writes to a given IO
def create_test_logger(io = $stdout)
  logger = Logger.new(io)
  logger.formatter = proc do |severity, datetime, progname, msg|
    "#{msg}\n"
  end
  logger
end