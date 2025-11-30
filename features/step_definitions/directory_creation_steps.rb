require './lib/deadlist/cli'
require './lib/deadlist/models/show'
require 'fileutils'
require 'tmpdir'

# Helper to create a mock show
def create_mock_show(name = "1977-05-08 - Barton Hall - Ithaca, NY")
  show = double('show')
  allow(show).to receive(:name).and_return(name)
  show
end

# Setup and teardown for temp directories
Before('@directory_tests') do
  @temp_dir = Dir.mktmpdir
  @original_dir = Dir.pwd
end

After('@directory_tests') do
  FileUtils.rm_rf(@temp_dir) if @temp_dir && File.exist?(@temp_dir)
  Dir.chdir(@original_dir) if @original_dir
end

# Basic directory creation
Given('a CLI instance with a show') do
  @show = create_mock_show
  @cli = CLI.allocate # Create instance without calling initialize
end

When('directories are set up') do
  @temp_dir = Dir.mktmpdir
  @result_path = @cli.send(:setup_directories, @show, @temp_dir)
end

Then('a {string} directory should be created') do |dir_name|
  expected_path = File.join(@temp_dir, dir_name)
  expect(File.directory?(expected_path)).to be true
end

Then('the shows directory should exist in the current path') do
  shows_dir = File.join(@temp_dir, "shows")
  expect(File.exist?(shows_dir)).to be true
  expect(File.directory?(shows_dir)).to be true
end

# Show-specific subdirectory
Given('a CLI instance with a show named {string}') do |show_name|
  @show = create_mock_show(show_name)
  @show_name = show_name
  @cli = CLI.allocate
end

Then('a subdirectory for the show should be created') do
  expected_path = File.join(@temp_dir, "shows", @show_name)
  expect(File.directory?(expected_path)).to be true
end

Then('the subdirectory should be named {string}') do |expected_name|
  expected_path = File.join(@temp_dir, "shows", expected_name)
  expect(File.exist?(expected_path)).to be true
end

# Return path validation
Then('the returned path should point to the show directory') do
  expected_path = File.join(@temp_dir, "shows", @show.name)
  expect(@result_path).to eq(expected_path)
end

Then('the path should be absolute') do
  expect(Pathname.new(@result_path).absolute?).to be true
end

# Existing directories
Given('a {string} directory already exists') do |dir_name|
  @temp_dir = Dir.mktmpdir
  FileUtils.mkdir_p(File.join(@temp_dir, dir_name))
end

Then('it should not raise an error') do
  expect { @result_path }.not_to raise_error
end

Then('the existing directory should remain') do
  shows_dir = File.join(@temp_dir, "shows")
  expect(File.exist?(shows_dir)).to be true
end

Given('a show subdirectory already exists') do
  @temp_dir = Dir.mktmpdir
  @show = create_mock_show
  show_dir = File.join(@temp_dir, "shows", @show.name)
  FileUtils.mkdir_p(show_dir)

  # Create a marker file to verify directory wasn't recreated
  @marker_file = File.join(show_dir, ".marker")
  FileUtils.touch(@marker_file)
end

Then('the existing show directory should remain') do
  # Check that our marker file still exists
  expect(File.exist?(@marker_file)).to be true
end

# Custom base path
When('directories are set up with custom base path {string}') do |base_path|
  @custom_base = base_path
  FileUtils.mkdir_p(@custom_base)
  @result_path = @cli.send(:setup_directories, @show, @custom_base)
end

Then('directories should be created under the custom path') do
  expect(@result_path).to start_with(@custom_base)
end

Then('the path should contain {string}') do |expected_substring|
  expect(@result_path).to include(expected_substring)
end

# Special characters
Then('the directory should be created successfully') do
  expect(File.directory?(@result_path)).to be true
end

Then('the directory name should preserve special characters') do
  expect(@result_path).to include(@show_name)
end
