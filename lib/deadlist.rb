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

    # Argument abstraction should probably happen at this level!

    def run(argv = ARGV)
      # Check for --quiet flag and adjust logger level
      if argv.include?('--quiet') || argv.include?('-q')
          @logger.level = Logger::ERROR
      end
      
      # Start a new CLI session
      # In future this could be abstracted to pass the show link vs all args, so a 'session' is started per show.
      session = CLI.new(@current_version, argv, logger: @logger)

      # Scrape links and metadata for given show
      session.create_show

      # In future, consider starting multiple downloaders for a list of shows
      # show_list = session.args[:shows]
      # show_list.each do |show|
      #   session.download_show(show)
      # end

      # Create folder with show date and begin track downloads if format matches
      session.download_show
    end
end

# Run DeadList
if __FILE__ == $0
  DeadList.new.run
  puts "\n"
end
