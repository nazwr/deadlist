require './lib/deadlist/cli/argument_parser'
require 'optparse'
require 'stringio'

# Valid arguments scenarios
Given('valid arguments with id {string} and format {string}') do |id, format|
  @args = ['--id', id, '--format', format]
end

When('the arguments are parsed') do
  @parsed_params = ArgumentParser.parse(@args, DeadList::VERSION)
end

Then('the parsed parameters should include the id') do
  expect(@parsed_params[:id]).not_to be_nil
  expect(@parsed_params[:id]).to be_a(String)
end

Then('the parsed parameters should include the format') do
  expect(@parsed_params[:format]).not_to be_nil
  expect(@parsed_params[:format]).to be_a(String)
end

# Valid arguments with output path
Given('valid arguments with id {string} and format {string} and directory {string}') do |id, format, directory|
  @args = ['--id', id, '--format', format, '--directory', directory]
end

Then('the parsed parameters should include the output directory') do
  expect(@parsed_params[:directory]).not_to be_nil
  expect(@parsed_params[:directory]).to eq('/custom/path')
end

# --dry-run flag
Given('valid arguments with id {string} and format {string} and --dry-run flag') do |id, format|
  @args = ['--id', id, '--format', format, '--dry-run']
end

Then('the parsed parameters should include dry_run as true') do
  expect(@parsed_params[:dry_run]).to be true
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
    ArgumentParser.parse(@args, DeadList::VERSION)
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
  expect(@error_message).to match(/Arguments are required/)
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
    ArgumentParser.parse(@args, DeadList::VERSION)
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
  expect(output_string).to match(/deadlist v#{DeadList::VERSION}/)
end

# Invalid option scenario
Given('arguments with invalid option {string}') do |invalid_option|
  @args = [invalid_option, '--id', 'test', '--format', 'mp3']
end

Then('it should exit with an error about invalid option') do
  expect(@exit_called).to be true
  expect(@error_message).to match(/invalid option/)
end

# Dry-run
Given('a CLI instance with --dry-run flag') do
  # Mock the Client to return test data
  mock_show_data = {
    date: "1977-05-08",
    location: "Ithaca, NY",
    venue: "Barton Hall",
    transferred_by: "Test User",
    duration: "3:05:00",
    dir: "gd1977-05-08",
    files: [
      {"name" => "track01.mp3", "title" => "New Minglewood Blues", "track" => "1", "format" => "VBR MP3"},
      {"name" => "track02.mp3", "title" => "Scarlet Begonias", "track" => "2", "format" => "VBR MP3"},
      {"name" => "track03.mp3", "title" => "Fire On The Mountain", "track" => "3", "format" => "VBR MP3"}
    ]}
    
  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_return(mock_show_data)
  allow(Client).to receive(:new).and_return(client_double)
  
  @output = StringIO.new
  @test_logger = create_test_logger(@output)
  @cli = CLI.new(DeadList::VERSION, ['--id', 'gd1977-05-08', '--format', 'mp3', '--dry-run'], logger: @test_logger)
  @temp_dir = Dir.mktmpdir
end

When('the show is created and downloaded with dry-run') do
  @cli.create_show
  @cli.download_show
end

Then('it should display the track list') do
  @output.rewind
  output_text = @output.read

  # Should show dry-run header with track count
  expect(output_text).to match(/Dry Run:.*will be downloaded with 3 tracks/)

  # Should list each track
  expect(output_text).to match(/New Minglewood Blues/)
  expect(output_text).to match(/Scarlet Begonias/)
  expect(output_text).to match(/Fire On The Mountain/)
  end

And('no files should be downloaded') do
  @output.rewind
  output_text = @output.read

  # Verify dry-run message appears (proving we're in dry-run mode)
  expect(output_text).to match(/Dry Run:/)

  # Verify actual download messages DON'T appear
  expect(output_text).not_to match(/⬇️ Downloading/)
end