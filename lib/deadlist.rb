require 'httparty'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'pry'

require './lib/deadlist/cli.rb'

# Main DeadList class.

# # What if you structured it like this?
# DeadList::Client       # Core scraping logic
# DeadList::CLI          # Command line interface  
# DeadList::Track        # Data model
# DeadList::Show         # Data model
# DeadList::Downloader   # Download orchestration

class DeadList
    def initialize
        @current_version = '1.0.0'
        @hostname = 'https://www.archive.org/'
        @links = []
        @preferred_format = nil
    end

    def run        
        session = CLI.new(@current_version, ARGV)
        session.process_links

        # process_links
        print_execution_report
    end

    def download_track(track)
        # Variable store
        track_name = nil
        track_links = []
        formats = []

        for child in track.children do
            if child.name == "meta" && child.attribute_nodes[0].value == "name"
                track_name = child.attribute_nodes[1].value
            elsif child.name == "link"
                # ❌ Why is this pushing 2x .mp3 files, vs each one seperately? 
                track_links << child.attribute_nodes[1].value
            end
        end

        if track_links.length > 1 && @preferred_format == nil
            for track in track_links
                formats << track[-3..]
            end

            puts "💾 Multiple formats of this show are avilable. #{formats}."
            while @preferred_format == nil
                puts "Please enter a format to download: "
                format_input = STDIN.gets.chomp
                
                for f in formats
                    if f == format_input
                        @preferred_format = f
                    end
                end
            end
        elsif @preferred_format == 'test'
            puts "🧪 Test command, skipping download"
        elsif track_links.length > 1 && @preferred_format != nil
            # Download file with matching format
            for track in track_links
                download = URI.open(track)
                # Get the trackname and pass it as the filename
                IO.copy_stream(download, "./track_name.#{@preferred_format}")  
            end
            
        elsif track_links.length < 1
            puts "\n❌ Error! Audio links are not available for this track."
        end

        puts "Now downloading: #{track_name}"
    end

    def process_links
        if @links.length == 0
            puts "\n❌ Error! No links found."
            # sleep(1)
        else
            puts "\n🔗 #{@links.length} Links found, processing..."
            # sleep(1)

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
                        puts "-" * 50
                        # sleep(1)
                        puts "\n#{track_array.length} tracks found!"
                        puts "-" * 50
                        
                        for track in track_array do
                            download_track(track)
                        end
                    end
                end
                # sleep(1)
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
