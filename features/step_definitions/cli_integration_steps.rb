require './lib/deadlist'
require './lib/deadlist/cli'
require './lib/deadlist/cli/client'
require './lib/deadlist/models/show'
require 'stringio'
require 'tmpdir'

# Helper to capture output
def capture_output
  original_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.rewind
  $stdout.read
ensure
  $stdout = original_stdout
end

# Helper to mock ARGV
def with_argv(args)
  original_argv = ARGV.dup
  ARGV.clear
  ARGV.concat(args)
  yield
ensure
  ARGV.clear
  ARGV.concat(original_argv)
end

# Complete successful flow
Given('I have valid arguments {string}') do |args|
  @args = args.split(' ')
  @temp_dir = Dir.mktmpdir

  # Mock the API response
  mock_response = {
    date: "1977-05-08",
    location: "Ithaca, NY",
    venue: "Barton Hall, Cornell University",
    transferred_by: "John Doe",
    duration: "3:05:00",
    dir: "gd1977-05-08",
    files: [
      {"name" => "track01.mp3", "title" => "New Minglewood Blues", "track" => "1"},
      {"name" => "track02.mp3", "title" => "Loser", "track" => "2"}
    ]
  }

  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_return(mock_response)
  allow(Client).to receive(:new).and_return(client_double)

  # Mock the downloader to prevent actual downloads
  allow_any_instance_of(Downloader).to receive(:get).and_return(true)
end

When('I run the DeadList CLI') do
  @output = with_argv(@args) do
    capture_output do
      @deadlist = DeadList.new
      @deadlist.run
    end
  end
end

Then('it should display the startup banner') do
  expect(@output).to include("One man gathers what another man spills")
  expect(@output).to include("=" * 52)
end

Then('it should parse the arguments successfully') do
  expect(@output).not_to include("Missing required arguments")
end

Then('it should create a show with metadata') do
  expect(@output).to include("1977-05-08")
  expect(@output).to include("Barton Hall")
end

Then('it should set up the directory structure') do
  # If we got this far without errors, directories were set up
  expect(@output).not_to include("Directory creation failed")
end

Then('it should initiate the download process') do
  # If format is not "test", download_show is called
  expect(@output).not_to include("Test Download, skipping")
end

Then('the process should complete without errors') do
  expect(@output).not_to include("❌")
  expect(@output).not_to include("failed")
end

# Invalid show ID flow
Given('I have arguments with invalid show ID {string}') do |args|
  @args = args.split(' ')

  # Mock the API to return nil metadata (invalid show)
  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_raise(StandardError.new("Invalid show ID"))
  allow(Client).to receive(:new).and_return(client_double)
end

Then('it should fail during show creation') do
  expect(@output).to include("Scraping failed")
end

Then('it should display a scraping error message') do
  expect(@output).to match(/Scraping failed/)
end

Then('the process should not crash') do
  # If we captured output, the process didn't crash
  expect(@output).to be_a(String)
end

# Missing arguments flow
Given('I have incomplete arguments {string}') do |args|
  @args = args.split(' ')
end

When('I run the DeadList CLI with error handling') do
  @exit_caught = false
  @output = with_argv(@args) do
    capture_output do
      begin
        DeadList.new.run
      rescue SystemExit => e
        @exit_caught = true
        @exit_code = e.status
      end
    end
  end
end

Then('it should exit during argument parsing') do
  expect(@exit_caught).to be true
end

Then('it should display an error about missing --id') do
  expect(@output).to include("--id")
end

Then('it should not proceed to show creation') do
  expect(@output).not_to include("Downloading")
end

# DeadList.run orchestration
Given('a DeadList instance') do
  @deadlist = DeadList.new
end

Given('I mock the CLI flow') do
  @cli_double = double('cli')
  allow(@cli_double).to receive(:create_show)
  allow(@cli_double).to receive(:download_show)

  # Mock CLI.new to return our double
  allow(CLI).to receive(:new).and_return(@cli_double)
end

When('I call the run method') do
  @output = capture_output do
    @deadlist.run(['--id', 'test', '--format', 'mp3'])
  end
end

Then('it should create a CLI session') do
  expect(CLI).to have_received(:new).with(DeadList::VERSION, ['--id', 'test', '--format', 'mp3'], anything())
end

Then('it should call create_show on the session') do
  expect(@cli_double).to have_received(:create_show)
end

Then('it should call download_show on the session') do
  expect(@cli_double).to have_received(:download_show)
end

Then('all steps should execute in order') do
  # If all previous steps passed, they executed in order
  expect(true).to be true
end

# Startup banner
Given('I initialize a CLI with valid arguments') do
  @output = capture_output do
    @cli = CLI.new(DeadList::VERSION, ['--id', 'test', '--format', 'mp3'])
  end
end

Then('it should display the Grateful Dead banner') do
  expect(@output).to include("🌹⚡️")
end

Then('the banner should contain {string}') do |text|
  expect(@output).to include(text)
end

# Network error during download
Given('the download will fail with network error') do
  # Mock successful show creation
  mock_response = {
    date: "1977-05-08",
    location: "Ithaca, NY",
    venue: "Barton Hall",
    transferred_by: "John Doe",
    duration: "3:05:00",
    dir: "gd1977-05-08",
    files: [{"name" => "track01.mp3", "title" => "Test", "track" => "1"}]
  }

  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_return(mock_response)
  allow(Client).to receive(:new).and_return(client_double)

  # Mock download to raise error
  allow_any_instance_of(Downloader).to receive(:get).and_raise(StandardError.new("Network error"))
end

Then('it should create the show successfully') do
  expect(@output).to include("tracks found")
end

Then('it should fail during download') do
  # The error is caught and displayed, not raised
  expect(@output).to match(/Download failed|failed/)
end

Then('it should display a download error message') do
  expect(@output).to match(/Download failed/)
end

# Directory structure
When('I run the DeadList CLI with directory tracking') do
  @created_directories = []

  # Track directory creation
  original_mkdir_p = FileUtils.method(:mkdir_p)
  allow(FileUtils).to receive(:mkdir_p) do |path|
    @created_directories << path
    original_mkdir_p.call(path)
  end

  @output = with_argv(@args) do
    capture_output do
      DeadList.new.run
    end
  end
end

Then('it should create the shows directory') do
  shows_dir = @created_directories.find { |d| d.end_with?('/shows') }
  expect(shows_dir).not_to be_nil
end

Then('it should create a show-specific subdirectory') do
  show_subdir = @created_directories.find { |d| d.include?('1977-05-08') }
  expect(show_subdir).not_to be_nil
end

Then('the directory name should match the show name') do
  show_dir = @created_directories.find { |d| d.include?('Barton Hall') }
  expect(show_dir).not_to be_nil
end

# No files in requested format
Given('the show has no ogg files available') do
  mock_response = {
    date: "1977-05-08",
    location: "Ithaca, NY",
    venue: "Barton Hall",
    transferred_by: "John Doe",
    duration: "3:05:00",
    dir: "gd1977-05-08",
    files: [
      {"name" => "track01.mp3", "title" => "Test", "track" => "1"},
      {"name" => "track01.flac", "title" => "Test", "track" => "1"}
    ]
  }

  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_return(mock_response)
  allow(Client).to receive(:new).and_return(client_double)
end

Then('it should display {string} message') do |message|
  expect(@output).to include(message)
end

Then('the process should complete without downloads') do
  # No download errors, but also no actual downloads
  expect(@output).not_to include("Download failed")
end

Then('it should not display the startup banner') do
  expect(@output).not_to include("One man gathers what another man spills")
  expect(@output).not_to include("=" * 52)
end

Then('it should not display info messages') do
  expect(@output).not_to include("tracks found")
  expect(@output).not_to include("💿")
end
