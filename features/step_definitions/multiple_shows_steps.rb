require './lib/deadlist/cli/argument_parser'
require './lib/deadlist/cli'
require './lib/deadlist/cli/client'
require './lib/deadlist/models/show'
require 'stringio'

# Scenario 1: Parse comma-separated show IDs

Given('valid arguments with ids {string} and format {string}') do |ids, format|
  @args = ['--id', ids, '--format', format]
end

Then('the parsed parameters should include {int} show IDs') do |count|
  expect(@parsed_params[:ids]).to be_an(Array)
  expect(@parsed_params[:ids].count).to eq(count)
end

# Scenario 2: Download multiple shows successfully

When('the shows are downloaded') do
  # Mock show data for both shows
  @mock_show_data_1 = {
    date: "1977-05-08",
    location: "Ithaca, NY",
    venue: "Barton Hall",
    transferred_by: "Test User",
    duration: "3:05:00",
    dir: "show1",
    files: [
      {"name" => "track01.mp3", "title" => "Track 1", "track" => "1", "format" => "VBR MP3"}
    ]
  }

  @mock_show_data_2 = {
    date: "1978-05-05",
    location: "Boston, MA",
    venue: "The Garden",
    transferred_by: "Test User",
    duration: "2:45:00",
    dir: "show2",
    files: [
      {"name" => "track01.mp3", "title" => "Track 1", "track" => "1", "format" => "VBR MP3"}
    ]
  }

  # Mock Client to return different data based on show_id
  client_double = double('client')
  allow(client_double).to receive(:query_show_info).with('show1').and_return(@mock_show_data_1)
  allow(client_double).to receive(:query_show_info).with('show2').and_return(@mock_show_data_2)
  allow(Client).to receive(:new).and_return(client_double)

  @output = StringIO.new
  @test_logger = create_test_logger(@output)

  # Create a DeadList instance and run with multiple show IDs
  deadlist = DeadList.new(logger: @test_logger)
  deadlist.run(@args)
end

Then('both shows should be processed sequentially') do
  @output.rewind
  output_text = @output.read

  # Should process both shows
  expect(output_text).to match(/1977-05-08.*Barton Hall/)
  expect(output_text).to match(/1978-05-05.*The Garden/)
end

And('progress should be displayed for each show') do
  @output.rewind
  output_text = @output.read

  # Should show progress (1/2, 2/2)
  expect(output_text).to match(/Processing show 1\/2/)
  expect(output_text).to match(/Processing show 2\/2/)
end

# Scenario 3: Handle format mismatch gracefully

Given('valid arguments with ids {string} and format {string}') do |ids, format|
  @show_ids = ids.split(',')
  @args = ['--id', ids, '--format', format]

  # Mock show data - first show has mp3, second doesn't
  @mock_show_with_mp3 = {
    date: "1977-05-08",
    location: "Ithaca, NY",
    venue: "Barton Hall",
    transferred_by: "Test User",
    duration: "3:05:00",
    dir: "show-with-mp3",
    files: [
      {"name" => "track01.mp3", "title" => "Track 1", "track" => "1", "format" => "VBR MP3"}
    ]
  }

  @mock_show_without_mp3 = {
    date: "1978-05-05",
    location: "Boston, MA",
    venue: "The Garden",
    transferred_by: "Test User",
    duration: "2:45:00",
    dir: "show-without-mp3",
    files: [
      {"name" => "track01.flac", "title" => "Track 1", "track" => "1", "format" => "Flac"},
      {"name" => "track01.ogg", "title" => "Track 1", "track" => "1", "format" => "Ogg Vorbis"}
    ]
  }
end

Then('the first show should download successfully') do
  @output.rewind
  output_text = @output.read

  expect(output_text).to match(/Barton Hall/)
end

And('the second show should display format error with available formats') do
  @output.rewind
  output_text = @output.read

  expect(output_text).to match(/not available in mp3 format/)
  expect(output_text).to match(/Available formats:/)
  expect(output_text).to match(/flac/)
  expect(output_text).to match(/ogg/)
end

And('the second show should be skipped') do
  @output.rewind
  output_text = @output.read

  expect(output_text).to match(/Skipping/)
  # Should NOT show successful download of second show
  expect(output_text).not_to match(/The Garden.*downloaded/)
end
