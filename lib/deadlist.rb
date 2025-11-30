require 'httparty'
require 'open-uri'
require 'pry'

require_relative 'deadlist/cli'

# Main DeadList class.
class DeadList
    attr_reader :current_version

    def initialize
        @current_version = '1.1.0'
    end

    # Argument abstraction should probably happen at this level!

    def run        
        # Start a new CLI session
        # In future this could be abstracted to pass the show link vs all args, so a 'session' is started per show.
        session = CLI.new(@current_version, ARGV)

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
