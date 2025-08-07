require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'pry'

require_relative 'deadlist/cli.rb'

# Main DeadList class.
class DeadList
    HOSTNAME = 'https://www.archive.org/'

    def initialize
        @current_version = '1.0.1'
        @hostname = HOSTNAME
    end

    # Argument abstraction should probably happen at this level!

    def run        
        # Start a new CLI session
        # In future this could be abstracted to pass the show link vs all args, so a 'session' is started per show.
        session = CLI.new(@current_version, ARGV)

        # Scrape links and metadata for given show
        session.scrape_links

        # Create folder with show date and begin track downloads if format matches
        session.download_show
    end
end

# Run DeadList
if __FILE__ == $0
  DeadList.new.run
  puts "\n"
end
