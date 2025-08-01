require_relative 'cli/client.rb'
require_relative 'cli/downloader.rb'
require_relative 'models/show.rb'
require 'fileutils'

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
        @show = Show.new(@args[:show])
        binding.pry
        return puts "\n❌ Error! No links found." if show_link.nil?
        
        # Change to show_data and pass to @show after formatting as Show class
        # @show = Client.new.scrape(show_link)
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

    def setup_directories(show, base_path = Dir.pwd)
        show_date = show[:show_name][-10..]

        # Create base shows directory
        shows_dir = File.join(base_path, "shows")
        FileUtils.mkdir_p(shows_dir)
        
        # Create specific show directory
        show_dir = File.join(shows_dir, show_date)
        FileUtils.mkdir_p(show_dir)

        return show_dir
    end

    def download_show
        if @download_format
            download_path = setup_directories(@show)

            # Download tracks to folder
            dl = Downloader.new(download_path, @download_format)

            for track in @show[:tracks]
                dl.get(track)
            end
        end
    end
end