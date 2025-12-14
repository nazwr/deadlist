Before do
  RSpec::Mocks.setup
  # Store original directory for cleanup
  @original_test_dir = Dir.pwd
end

After do
  begin
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end

  # Clean up any shows directory created during tests
  shows_dir = File.join(@original_test_dir, 'shows')
  FileUtils.rm_rf(shows_dir) if File.exist?(shows_dir)
end