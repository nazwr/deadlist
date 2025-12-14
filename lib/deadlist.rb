require 'httparty'
require 'open-uri'
require 'pry'
require 'logger'

require_relative 'deadlist/version'
require_relative 'deadlist/cli'

# Main DeadList class.
class DeadList
    attr_reader :current_version

    def initialize(logger: Logger.new($stdout))
      @logger = logger
      @logger.level = Logger::INFO  # Default level
      @logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
      end
      @current_version = VERSION
    end

    def run(argv = ARGV)
      # Parse arguments to get show IDs and options
      parsed_args = ArgumentParser.parse(argv, @current_version)
      show_ids = parsed_args[:ids]

      # Check for --quiet flag and adjust logger level
      if parsed_args[:quiet]
          @logger.level = Logger::ERROR
      end

      # Process each show
      show_ids.each_with_index do |show_id, index|
        @logger.info "📻 Processing show #{index + 1}/#{show_ids.count}: #{show_id}"

        # Build arguments for this specific show
        show_argv = ['--id', show_id, '--format', parsed_args[:format]]
        show_argv += ['--directory', parsed_args[:directory]] if parsed_args[:directory]
        show_argv += ['--quiet'] if parsed_args[:quiet]
        show_argv += ['--dry-run'] if parsed_args[:dry_run]

        # Create CLI session for this show
        session = CLI.new(@current_version, show_argv, logger: @logger)

        # Scrape links and metadata for given show
        session.create_show

        # Check if show has tracks in requested format
        if session.show && session.show.tracks.empty?
          @logger.error "❌ #{show_id} not available in #{parsed_args[:format]} format"
          if session.show.available_formats && !session.show.available_formats.empty?
            @logger.error "   Available formats: #{session.show.available_formats.join(', ')}"
          end
          @logger.error "   Skipping..."
          next  # Skip to next show
        end

        # Create folder and begin track downloads
        session.download_show
      end
    end
end

# Run DeadList
if __FILE__ == $0
  DeadList.new.run
  puts "\n"
end
