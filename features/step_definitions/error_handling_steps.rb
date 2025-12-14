require './lib/deadlist/cli'
require './lib/deadlist/cli/client'
require './lib/deadlist/models/show'
require 'stringio'

# Invalid show ID
Given('an ArgumentParser with show ID {string}') do |show_id|
  @show_id = show_id
end

When('the client attempts to fetch show info') do
  @error = nil
  @client = Client.new

  # Mock HTTParty to return response without metadata
  response_double = double('response')
  allow(response_double).to receive(:success?).and_return(true)
  allow(response_double).to receive(:[]).with("metadata").and_return(nil)
  allow(HTTParty).to receive(:get).and_return(response_double)

  begin
    @client.query_show_info(@show_id)
  rescue => e
    @error = e
  end
end

Then('it should raise an invalid show error') do
  expect(@error).not_to be_nil
  expect(@error.message).to match(/Invalid show ID/)
end

Then('the error message should mention {string}') do |show_id|
  expect(@error.message).to include(show_id)
end

# Network timeout
Given('a show ID that causes network timeout') do
  @show_id = "timeout-test"
  @client = Client.new

  # Mock HTTParty to simulate timeout
  allow(HTTParty).to receive(:get).and_raise(Timeout::Error.new("execution expired"))
end

Then('it should raise an error about failed request') do
  expect(@error).not_to be_nil
  expect(@error.message).to match(/Failed to fetch show data/)
end

Then('the error message should be user-friendly') do
  expect(@error.message).to be_a(String)
  expect(@error.message.length).to be > 0
end

# Malformed JSON
Given('an API response with malformed JSON') do
  @client = Client.new

  # Mock response that causes JSON parse error
  response_double = double('response')
  allow(response_double).to receive(:success?).and_return(true)
  allow(response_double).to receive(:[]).and_raise(JSON::ParserError.new("unexpected token"))
  allow(HTTParty).to receive(:get).and_return(response_double)
end

When('the client attempts to parse the response') do
  @error = nil

  begin
    @client.query_show_info("test-show")
  rescue => e
    @error = e
  end
end

Then('it should raise an error about failed fetch') do
  expect(@error).not_to be_nil
  expect(@error.message).to match(/Failed to fetch show data/)
end

Then('the error should be caught gracefully') do
  expect(@error).to be_a(StandardError)
  expect(@error.message).not_to be_empty
end

# URL extraction
Given('an invalid archive.org URL {string}') do |url|
  @url = url
  @cli = CLI.allocate
  @cli.instance_variable_set(:@logger, Logger.new($stdout))
end

When('the CLI extracts the show ID') do
  @extracted_id = @cli.send(:extract_show_id, @url)
end

Then('it should return the original input') do
  expect(@extracted_id).to eq(@url)
end

Then('not raise an error') do
  expect { @extracted_id }.not_to raise_error
end

Given('a valid archive.org URL {string}') do |url|
  @url = url
  @cli = CLI.allocate
  @cli.instance_variable_set(:@logger, Logger.new($stdout))
end

Then('it should return {string}') do |expected_id|
  expect(@extracted_id).to eq(expected_id)
end

# Missing metadata fields
Given('an API response missing some metadata fields') do
  @response_data = {
    date: "1977-05-08",
    location: nil,  # Missing
    venue: "Barton Hall",
    transferred_by: nil,  # Missing
    duration: "3:05:00",
    dir: "gd1977-05-08",
    files: [
      {"name" => "track01.mp3", "title" => "Test", "track" => "1"}
    ]
  }

  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_return(@response_data)
  allow(Client).to receive(:new).and_return(client_double)
end

When('a show is created from the response') do
  suppress_output do
    @show = Show.new("gd1977-05-08", "mp3")
  end
end

Then('it should handle nil values gracefully') do
  expect(@show.location).to be_nil
  expect(@show.transferred_by).to be_nil
end

Then('the show should still be created') do
  expect(@show).to be_a(Show)
  expect(@show.date).to eq("1977-05-08")
  expect(@show.venue).to eq("Barton Hall")
end

# Empty files array
Given('an API response with empty files array') do
  response_data = {
    date: "1977-05-08",
    location: "Ithaca, NY",
    venue: "Barton Hall",
    transferred_by: "John Doe",
    duration: "3:05:00",
    dir: "gd1977-05-08",
    files: []
  }

  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_return(response_data)
  allow(Client).to receive(:new).and_return(client_double)
end

When('a show is created with format {string}') do |format|
  suppress_output do
    @show = Show.new("gd1977-05-08", format)
  end
end

Then('the tracks array should be empty') do
  expect(@show.tracks).to be_empty
end

Then('no error should be raised') do
  expect { @show }.not_to raise_error
end

# CLI error handling - show creation
Given('a CLI instance with invalid arguments') do
  # Mock Client to raise error
  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_raise(StandardError.new("Invalid show"))
  allow(Client).to receive(:new).and_return(client_double)

  # Create CLI instance
  args = ['--id', 'invalid-show', '--format', 'mp3']
  suppress_output do
    @cli = CLI.new(DeadList::VERSION, args)
  end
end

When('create_show is called') do
  @output = StringIO.new
  @test_logger = create_test_logger(@output)
  @cli.instance_variable_set(:@logger, @test_logger)

  @cli.create_show
end

Then('it should catch the error and not crash') do
  # If no error was raised, the rescue block worked
  expect { @cli }.not_to raise_error
end

Then('display a user-friendly error message') do
  @output.rewind
  output_text = @output.read
  expect(output_text).to match(/Scraping failed/)
end

Then('not crash the application') do
  expect(@cli).to be_a(CLI)
end

# CLI error handling - download
Given('a CLI instance with a valid show') do
  # Create a mock show
  @mock_show = double('show')
  allow(@mock_show).to receive(:name).and_return("Test Show")
  allow(@mock_show).to receive(:download_tracks).and_raise(StandardError.new("Network error"))

  args = ['--id', 'gd1977-05-08', '--format', 'mp3']
  suppress_output do
    @cli = CLI.new(DeadList::VERSION, args)
  end

  # Inject the mock show
  @cli.instance_variable_set(:@show, @mock_show)
end

When('download fails due to network error') do
  @output = StringIO.new
  @test_logger = create_test_logger(@output)
  @cli.instance_variable_set(:@logger, @test_logger)

  @cli.download_show
end

Then('display download failed message') do
  @output.rewind
  output_text = @output.read
  expect(output_text).to match(/Download failed/)
end

# Directory permission error
Given('a base path without write permissions') do
  @base_path = "/root/restricted"  # Typically no write access for regular users
  @cli = CLI.allocate
  @cli.instance_variable_set(:@logger, Logger.new($stdout))
  @show = double('show', name: "Test Show")
end

When('directories are set up with permission error') do
  @output = StringIO.new
  @test_logger = create_test_logger(@output)
  @cli.instance_variable_set(:@logger, @test_logger)

  # Mock FileUtils to simulate permission error
  allow(FileUtils).to receive(:mkdir_p).and_raise(Errno::EACCES.new("Permission denied"))

  @cli.send(:setup_directories, @show, @base_path)
end

Then('it should catch the permission error') do
  # If we get here, the error was caught
  expect(true).to be true
end

Then('display directory creation failed message') do
  @output.rewind
  output_text = @output.read
  expect(output_text).to match(/Directory creation failed/)
end

# Helper method
def suppress_output
  original_stdout = $stdout
  $stdout = StringIO.new
  yield
ensure
  $stdout = original_stdout
end
