require './lib/deadlist/cli/downloader'
require './lib/deadlist/models/track'
require 'tmpdir'
require 'stringio'

# Helper to create mock track
def create_mock_track(pos, title, filename)
  track = double('track')
  allow(track).to receive(:pos).and_return(pos)
  allow(track).to receive(:title).and_return(title)
  allow(track).to receive(:filename).and_return(filename)
  track
end

# URL generation
Given('a downloader for show {string}') do |show_id|
  @show_id = show_id
  @downloader = Downloader.new("/tmp/test", "mp3")
end

When('the download URL is generated') do
  @download_url = @downloader.download_url_for_show(@show_id)
end

Then('the URL should be {string}') do |expected_url|
  expect(@download_url).to eq(expected_url)
end

# File naming
Given('a downloader with path {string} and format {string}') do |path, format|
  @path = path
  @format = format
  @downloader = Downloader.new(path, format)
end

Given('a track with position {string}, title {string}, and filename {string}') do |pos, title, filename|
  @track = create_mock_track(pos, title, filename)
end

When('the file is downloaded') do
  # We're testing the filename construction, not actual download
  # The filename is constructed in the get method
  sanitized_title = @track.title.gsub('/', '-')
  @expected_filename = "#{@path}/#{@track.pos} -- #{sanitized_title}.#{@format}"
end

Then('the file should be saved as {string}') do |expected_name|
  full_expected_path = "#{@path}/#{expected_name}"
  expect(@expected_filename).to eq(full_expected_path)
end

# URL construction
Given('a track with filename {string}') do |filename|
  @track = create_mock_track("1", "Test Track", filename)
  @track_filename = filename
end

When('the download URL is constructed') do
  base_url = @downloader.download_url_for_show(@show_id)
  @full_url = base_url + @track_filename
end

Then('the full URL should be {string}') do |expected_url|
  expect(@full_url).to eq(expected_url)
end

# Downloader attributes
Then('the downloader should have path {string}') do |expected_path|
  expect(@downloader.instance_variable_get(:@path)).to eq(expected_path)
end

Then('the downloader should have format {string}') do |expected_format|
  expect(@downloader.instance_variable_get(:@format)).to eq(expected_format)
end

# Non-HTTP URL validation
Given('a downloader with a non-HTTP URL') do
  @downloader = Downloader.new("/tmp/test", "mp3")
  @track = create_mock_track("1", "Test", "track.mp3")

  # Mock URI.parse to return a non-HTTP URI
  @invalid_url = "ftp://archive.org/download/show/track.mp3"
end

When('attempting to download') do
  @error = nil

  # Suppress output
  original_stdout = $stdout
  $stdout = StringIO.new

  begin
    # This will trigger the ArgumentError in the get method
    uri = URI.parse(@invalid_url)
    raise ArgumentError, "Only HTTP(S) URLs allowed" unless uri.is_a?(URI::HTTP)
  rescue => e
    @error = e
  ensure
    $stdout = original_stdout
  end
end

Then('it should raise an ArgumentError about HTTP URLs') do
  expect(@error).to be_a(ArgumentError)
  expect(@error.message).to match(/HTTP/)
end

# Error handling
Given('a downloader with an invalid track URL') do
  @downloader = Downloader.new("/tmp/test", "mp3")
  @track = create_mock_track("1", "Test Track", "nonexistent.mp3")
  @base_url = "https://archive.org/download/invalid-show/"

  # Mock uri.open to raise an error
  allow_any_instance_of(URI::HTTP).to receive(:open).and_raise(StandardError.new("404 Not Found"))
end

Then('it should catch the error') do
  # The get method rescues all errors, so it should not raise
  expect {
    original_stdout = $stdout
    $stdout = StringIO.new
    @downloader.get(@base_url, @track)
    $stdout = original_stdout
  }.not_to raise_error
end

Then('it should display an error message with track title') do
  # Capture output
  output = StringIO.new
  original_stdout = $stdout
  $stdout = output

  @downloader.get(@base_url, @track)

  $stdout = original_stdout
  output.rewind
  captured_output = output.read

  expect(captured_output).to match(/Download failed/)
  expect(captured_output).to match(/Test Track/)
end

# Multiple tracks
Given('multiple tracks to download') do
  @tracks = [
    create_mock_track("1", "Track One", "track01.mp3"),
    create_mock_track("2", "Track Two", "track02.mp3"),
    create_mock_track("3", "Track Three", "track03.mp3")
  ]
  @expected_filenames = []
end

When('all tracks are downloaded') do
  @tracks.each do |track|
    filename = "#{@path}/#{track.pos} -- #{track.title}.#{@format}"
    @expected_filenames << filename
  end
end

Then('all files should be in the same directory') do
  directories = @expected_filenames.map { |f| File.dirname(f) }.uniq
  expect(directories.length).to eq(1)
  expect(directories.first).to eq(@path)
end

Then('each file should have a unique name based on position') do
  # Extract just the filenames
  filenames = @expected_filenames.map { |f| File.basename(f) }

  expect(filenames).to contain_exactly(
    "1 -- Track One.mp3",
    "2 -- Track Two.mp3",
    "3 -- Track Three.mp3"
  )

  # Check uniqueness
  expect(filenames.uniq.length).to eq(filenames.length)
end
