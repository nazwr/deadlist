require './lib/deadlist/cli/argument_parser'
require 'optparse'
require 'stringio'

# Valid arguments scenarios
Given('valid arguments with id {string} and format {string}') do |id, format|
  @args = ['--id', id, '--format', format]
end

When('the arguments are parsed') do
  @parsed_params = ArgumentParser.parse(@args, '1.1.0')
end

Then('the parsed parameters should include the id') do
  expect(@parsed_params[:id]).not_to be_nil
  expect(@parsed_params[:id]).to be_a(String)
end

Then('the parsed parameters should include the format') do
  expect(@parsed_params[:format]).not_to be_nil
  expect(@parsed_params[:format]).to be_a(String)
end

# Missing argument scenarios
Given('arguments with only format {string}') do |format|
  @args = ['--format', format]
end

Given('arguments with only id {string}') do |id|
  @args = ['--id', id]
end

Given('no arguments are provided') do
  @args = []
end

When('the arguments are parsed with error handling') do
  @exit_called = false
  @error_message = nil
  @output = []

  # Capture stdout
  original_stdout = $stdout
  $stdout = StringIO.new

  begin
    ArgumentParser.parse(@args, '1.1.0')
  rescue SystemExit => e
    @exit_called = true
    @exit_code = e.status
  ensure
    $stdout.rewind
    @output = $stdout.read.split("\n")
    $stdout = original_stdout
  end

  # Extract error message from output
  @error_message = @output.find { |line| line.include?('Error') }
end

Then('it should exit with an error about missing --id') do
  expect(@exit_called).to be true
  expect(@error_message).to match(/--id/)
end

Then('it should exit with an error about missing --format') do
  expect(@exit_called).to be true
  expect(@error_message).to match(/--format/)
end

Then('it should exit with an error about missing required arguments') do
  expect(@exit_called).to be true
  expect(@error_message).to match(/Missing required arguments/)
end

# Case-insensitive format
Then('the format should be converted to lowercase') do
  expect(@parsed_params[:format]).to eq('mp3')
end

# Help and version flags
Given('the --help flag is provided') do
  @args = ['--help']
end

Given('the --version flag is provided') do
  @args = ['--version']
end

When('the arguments are parsed with exit handling') do
  @exit_called = false
  @output = []

  # Capture stdout
  original_stdout = $stdout
  $stdout = StringIO.new

  begin
    ArgumentParser.parse(@args, '1.1.0')
  rescue SystemExit => e
    @exit_called = true
  ensure
    $stdout.rewind
    @output = $stdout.read.split("\n")
    $stdout = original_stdout
  end
end

Then('it should display the usage banner') do
  expect(@exit_called).to be true
  output_string = @output.join("\n")
  expect(output_string).to match(/Usage: deadlist/)
end

Then('it should display the version number') do
  expect(@exit_called).to be true
  output_string = @output.join("\n")
  expect(output_string).to match(/deadlist v1\.1\.0/)
end

# Invalid option scenario
Given('arguments with invalid option {string}') do |invalid_option|
  @args = [invalid_option, '--id', 'test', '--format', 'mp3']
end

Then('it should exit with an error about invalid option') do
  expect(@exit_called).to be true
  expect(@error_message).to match(/invalid option/)
end
