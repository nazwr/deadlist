require './lib/deadlist/client.rb'

class CLI
    def initialize(version, args)
        @version = version
        @args = {}
        @show = nil

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
        default_format = @args[:format]
    end
end