require './lib/deadlist/cli/client'
require './lib/deadlist/models/show'
require './lib/deadlist/models/track'
require 'rspec/mocks'
require 'stringio'

# Mock API response data
def mock_successful_response
  {
    "metadata" => {
      "date" => "1977-05-08",
      "coverage" => "Ithaca, NY",
      "venue" => "Barton Hall, Cornell University",
      "transferer" => "John Doe",
      "runtime" => "3:05:00",
      "identifier" => "gd1977-05-08.sbd.hicks.4136.sbeok.shnf"
    },
    "files" => [
      {"name" => "track01.mp3"},
      {"name" => "track02.mp3"},
      {"name" => "track01.flac"},
      {"name" => "info.txt"}
    ]
  }
end

def mock_response_no_mp3
  {
    "metadata" => {
      "date" => "1977-05-08",
      "coverage" => "Ithaca, NY",
      "venue" => "Barton Hall, Cornell University",
      "transferer" => "John Doe",
      "runtime" => "3:05:00",
      "identifier" => "gd1977-05-08.sbd.hicks.4136.sbeok.shnf"
    },
    "files" => [
      {"name" => "track01.flac"},
      {"name" => "track02.flac"},
      {"name" => "info.txt"}
    ]
  }
end

# Client class tests
Given('a valid show ID {string}') do |show_id|
  @show_id = show_id

  # Mock HTTParty response
  response_double = double('response')
  allow(response_double).to receive(:success?).and_return(true)
  allow(response_double).to receive(:[]).with("metadata").and_return(mock_successful_response["metadata"])
  allow(response_double).to receive(:[]).with("files").and_return(mock_successful_response["files"])
  allow(HTTParty).to receive(:get).and_return(response_double)
end

When('the client queries the show info') do
  @client = Client.new
  @show_data = @client.query_show_info(@show_id)
end

Then('the response should include show metadata') do
  expect(@show_data).to be_a(Hash)
  expect(@show_data).not_to be_empty
end

Then('the metadata should contain date information') do
  expect(@show_data[:date]).not_to be_nil
  expect(@show_data[:date]).to eq("1977-05-08")
end

Then('the metadata should contain venue information') do
  expect(@show_data[:venue]).not_to be_nil
  expect(@show_data[:venue]).to eq("Barton Hall, Cornell University")
end

Then('the metadata should contain location information') do
  expect(@show_data[:location]).not_to be_nil
  expect(@show_data[:location]).to eq("Ithaca, NY")
end

Then('the metadata should contain files list') do
  expect(@show_data[:files]).to be_a(Array)
  expect(@show_data[:files]).not_to be_empty
end

# Error handling tests
Given('an invalid show ID {string}') do |show_id|
  @show_id = show_id

  # Mock response with no metadata
  response_double = double('response')
  allow(response_double).to receive(:success?).and_return(true)
  allow(response_double).to receive(:[]).with("metadata").and_return(nil)
  allow(HTTParty).to receive(:get).and_return(response_double)
end

Given('a show ID that causes API failure') do
  @show_id = "some-show-id"

  # Mock failed response
  response_double = double('response')
  allow(response_double).to receive(:success?).and_return(false)
  allow(response_double).to receive(:code).and_return(404)
  allow(HTTParty).to receive(:get).and_return(response_double)
end

When('the client queries the show info with error handling') do
  @client = Client.new
  @error = nil

  begin
    @client.query_show_info(@show_id)
  rescue => e
    @error = e
  end
end

Then('it should raise an error about invalid show ID') do
  expect(@error).not_to be_nil
  expect(@error.message).to match(/Invalid show ID/)
end

Then('it should raise an error about API request failure') do
  expect(@error).not_to be_nil
  expect(@error.message).to match(/API request failed/)
end

# Show class tests
Given('a show with valid metadata') do
  # Mock the Client to return our test data
  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_return({
    date: "1977-05-08",
    location: "Ithaca, NY",
    venue: "Barton Hall, Cornell University",
    transferred_by: "John Doe",
    duration: "3:05:00",
    dir: "gd1977-05-08.sbd.hicks.4136.sbeok.shnf",
    files: [
      {"name" => "track01.mp3"},
      {"name" => "track02.mp3"}
    ]
  })
  allow(Client).to receive(:new).and_return(client_double)
end

Given('a show with metadata but no mp3 files') do
  # Mock the Client to return test data with no mp3 files
  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_return({
    date: "1977-05-08",
    location: "Ithaca, NY",
    venue: "Barton Hall, Cornell University",
    transferred_by: "John Doe",
    duration: "3:05:00",
    dir: "gd1977-05-08.sbd.hicks.4136.sbeok.shnf",
    files: [
      {"name" => "track01.flac"},
      {"name" => "track02.flac"}
    ]
  })
  allow(Client).to receive(:new).and_return(client_double)

  # Capture stdout to suppress "No mp3 files found" message
  @original_stdout = $stdout
  $stdout = StringIO.new
end

When('a Show object is created with id {string} and format {string}') do |show_id, format|
  # Capture the "Downloading..." output
  original_stdout = $stdout
  $stdout = StringIO.new

  @show = Show.new(show_id, format)

  $stdout = original_stdout
end

Then('the show name should be formatted correctly') do
  expect(@show.name).to eq("1977-05-08 - Barton Hall, Cornell University - Ithaca, NY")
end

Then('the show should have date set') do
  expect(@show.date).to eq("1977-05-08")
end

Then('the show should have venue set') do
  expect(@show.venue).to eq("Barton Hall, Cornell University")
end

Then('the show should have location set') do
  expect(@show.location).to eq("Ithaca, NY")
end

Then('the show should have duration set') do
  expect(@show.duration).to eq("3:05:00")
end

Then('the show should have transferred_by set') do
  expect(@show.transferred_by).to eq("John Doe")
end

Then('the show should have an empty tracks list') do
  # Restore stdout
  $stdout = @original_stdout if @original_stdout

  expect(@show.tracks).to be_a(Array)
  expect(@show.tracks).to be_empty
end
