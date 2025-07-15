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

        sleep(1)
    end

    def handle_request
        if @links.length == 0
            puts "\n❌ Error! No links found."
            sleep(1)
        else
            puts "\n🔗 #{@links.length} Links found, processing..."
            sleep(1)

            for link in @links do
                if !link.include? "archive.org"
                    puts "\n❌ Error! Only links from archive.org are currently supported."
                else
                    parsed_page_source = Nokogiri::HTML(HTTParty.get(link).body)
                    show_name = parsed_page_source.css('span[itemprop="name"]')[0].content
                    track_array = parsed_page_source.css('div[itemprop="track"]')

                    if track_array.length == 0
                        puts "\n❌ Error! No tracks found on page. Please double check link:#{link}."
                    else
                        puts "\n💀 Next Up: #{show_name.to_s}"
                        puts "-" * show_name.to_s.length
                        sleep(1)
                        puts "#{track_array.length} tracks found!"
                    end
                end
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
  puts "\n"
end
