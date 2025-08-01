require 'httparty'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'pry'

require_relative 'deadlist/cli.rb'

# Main DeadList class.
class DeadList
    def initialize
        @current_version = '1.0.0'
        @hostname = 'https://www.archive.org/'
    end

    def run        
        # Start a new download session
        # In future this could be abstracted to pass the show link vs all args, so a 'session' is started per show.
        session = CLI.new(@current_version, ARGV)

        # Scrape links for given show
        session.scrape_links
        
        # Request download format input from users if no default set or no format matches default. Prints format.
        session.validate_format

        # Create folder with show date and begin track downloads.
        session.download_show

        # Tidy up with an execution report
        print_execution_report
    end
end

# Run DeadList
if __FILE__ == $0
  DeadList.new.run
  puts "\n"
end
