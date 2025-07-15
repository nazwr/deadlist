require 'httparty'
require 'json'
require 'nokogiri'
require 'pry'

# Main DeadList class.
class DeadList
    def initialize
        @version = '1.0.0'
        @hostname = 'https://www.archive.org/'
        @links = []
        @ARGS = []
    end

    def run
        puts "\n🌹⚡️ One man gathers what another man spills..."
        puts '='*50
        sleep(1)
        
        handle_arguments
        handle_request
        print_execution_report
    end
    
    def handle_arguments
        for arg in ARGV do
            split_string = arg.split('=')
            @ARGS.push(split_string)
        end

        for arg in @ARGS
            argument_name = arg[0]
            argument_payload = arg[1]

            if argument_name == '--version'
                puts '1.0.0'
                puts '=' * 50 + "\n"
                puts 
            end

            if argument_name == '--links'
                @links = argument_payload.split(",")
            end

            if argument_name == '--format'
                puts "\n💾 #{argument_payload.to_s} set as default format"
            end
        end
    end

    def handle_request
        if @links.length == 0
            puts "\n❌ Error! No links found."
            sleep(1)
        else
            puts "\n🔗 #{@links.length} Links found, processing..."
            sleep(1)

            for link in @links do
                page_source = HTTParty.get(link)
                parsed_page_source = Nokogiri::HTML(page_source)

                track_array = parsed_page_source.css('div[itemprop="track"]')
                puts track_array.length
                sleep(1)
            end
        end
    end

    def print_execution_report
    end
end

# Run DeadList
if __FILE__ == $0
  DeadList.new.run
end
