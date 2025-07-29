require './lib/deadlist/cli/client.rb'
require "readline"

class CLI
    def initialize(version, args)
        @version = version
        @args = {}
        @show = nil
        @download_format = nil

        startup_text
        parse_arguments(args)
    end

    # Add a --quiet startup option for 
    def startup_text
        puts "\n\n"
        puts '='*52
        puts "🌹⚡️ One man gathers what another man spills... ⚡️🌹"
        puts '='*52
        puts ' '*23 + "v#{@version}"
        puts (' '*10) + ('='*32) + (' '*10)
    end

    def parse_arguments(args)
        args.each do |arg|
            key, value = arg.split('=')
            @args[key.tr('--', '').to_sym] = value
        end
    end

    def scrape_links
        show_link = @args[:show]
        return puts "\n❌ Error! No links found." if show_link.nil?
        
        # Change to show_data and pass to @show after formatting as Show class
        @show = Client.new.scrape(show_link)
        puts "\n💿 #{@show[:tracks].length} tracks found!"
    rescue => e
        puts "\n❌ Scraping failed: #{e.message}"
    end

    def validate_format
        preferred_format = @args[:format]
        # Move to Show class eventually
        # Get show formats in an array
        if preferred_format == "test"
            puts "\n💾 #{preferred_format} execution. Skipping download..."
            return
        elsif !preferred_format.nil?
            for link in @show[:tracks][0][:links]
                format = link[-3..]

                if format == preferred_format
                    @download_format = format
                    puts "\n💾 .#{format} found for this show. Downloading..."
                    return                    
                end
            end

            puts "\n#‼️ .#{preferred_format} not found for this show!"

        elsif preferred_format.nil?
            available_formats = []
            for format in @show[:tracks][0][:links]
                available_formats << format[-3..]
            end
            puts "\n‼️ No format given! #{available_formats} available for this show."
        end
    end

    def download_show
        if @download_format
            # Require this from --args
            download_folder = "./shows/#{@show[:show_name][-10..]}"
            # Create folder
            Dir.mkdir download_folder
            # Download tracks to folder
            downloader = Downloader.new

            for track in @show[:tracks]
                downloader.get(track)
            end
        end
    end
end