require 'rspec/expectations'
require 'rspec/mocks'

World(RSpec::Mocks::ExampleMethods)

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true