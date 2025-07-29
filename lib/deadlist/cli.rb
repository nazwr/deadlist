require './lib/deadlist/client.rb'
require "readline"

class CLI
    def initialize(version, args)
        @version = version
        @args = {}
        @show = nil
        @format = nil

        startup_text
        parse_arguments(args)
    end

    def startup_text
        puts "\n\n"
        puts '='*52
        puts "🌹⚡️ One man gathers what another man spills... ⚡️🌹"
        puts '='*52
        puts ' '*23 + "v#{@version}"
        puts (' '*10) + ('='*32) + (' '*10)
    end

    def parse_arguments(args)
        for arg in args do
            split_string = arg.split('=')            
            @args[split_string[0].tr('--', '').to_sym] = split_string[1]
        end
    end

    def scrape_links
        show_link = @args[:show]

        if show_link.nil?
            puts "\n❌ Error! No links found."
        else
            @show = Client.new.scrape(show_link)
        end
    end

    def validate_format
        preferred_format = @args[:format]

        if preferred_format.nil?
            puts "\n💾 No preferred format selected! Please select from the formats for this show."
        elsif
            # Show does not have default format in list
            # puts "\n💾 #{preferred_format} not found for this show! Formats available:"
            prompt = "> "
            while buf = Readline.readline(prompt, true)
                puts "Your input was: '#{buf}'"
            end
        else
            # Show has default format
            @format = preferred_format
            puts "\n💾 #{preferred_format} found for this show. Downloading..."
        end
    end
end