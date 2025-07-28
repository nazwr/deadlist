require './lib/deadlist/client.rb'

class CLI
    def initialize(version, args)
        @version = version
        @args = args
        @arg_obj = {}

        startup_text
        parse_arguments
    end

    def startup_text
        puts "\n\n"
        puts '='*52
        puts "🌹⚡️ One man gathers what another man spills... ⚡️🌹"
        puts '='*52
        puts ' '*23 + "v#{@version}"
        puts (' '*10) + ('='*32) + (' '*10)
    end

    def parse_arguments
        for arg in @args do
            split_string = arg.split('=')            
            @arg_obj[split_string[0].tr('--', '')] = split_string[1]
        end
    end

    def scrape_links
        show_link = @arg_obj["show"]

        if show_link == nil
            puts "\n❌ Error! No links found."
        else
            return Client.new.scrape(show_link)
        end
        # puts "\n🔗 #{@links.length} Links found, processing..."
            # # sleep(1)

            # for link in @links do
            #     if !link.include? "archive.org"
            #         puts "\n❌ Error! Only links from archive.org are currently supported."
            #     else
            #         parsed_page_source = Nokogiri::HTML(HTTParty.get(link).body)
            #         show_name = parsed_page_source.css('span[itemprop="name"]')[0].content
            #         track_array = parsed_page_source.css('div[itemprop="track"]')

            #         if track_array.length == 0
            #             puts "\n❌ Error! No tracks found on page. Please double check link:#{link}."
            #         else
            #             puts "\n💀 Next Up: #{show_name.to_s}"
            #             puts "-" * 50
            #             # sleep(1)
            #             puts "\n#{track_array.length} tracks found!"
            #             puts "-" * 50
                        
            #             for track in track_array do
            #                 download_track(track)
            #             end
            #         end
            #     end
            #     # sleep(1)
            # end
    end

    # def run_arguments
    #     for arg in @args_array do
    #         # Variable store
    #         argument_name = arg[0]
    #         argument_payload = arg[1]

    #         # Check for links string and split as an array
    #         if argument_name == '--links'
    #             @links = argument_payload.split(",")
    #         end

    #         # Check for format flag and set it as defualt if there
    #         if argument_name == '--format'
    #             @preferred_format = argument_payload.to_s

    #             puts "\n💾 #{argument_payload.to_s} set as default format"
    #         end
    #     end
    # end
end