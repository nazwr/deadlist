require_relative 'cli/client'
require_relative 'cli/downloader'
require_relative 'models/show'
require_relative 'models/track'
require 'fileutils'

class CLI
    def initialize(version, args)
        @version = version
        @args = {}
        @show = nil

        startup_text
        parse_arguments(args)
    end

    def parse_arguments(args)
        args.each do |arg|
            key, value = arg.split('=')
            @args[key.tr('--', '').to_sym] = value
        end
    end

    def scrape_links
        @show = Show.new(@args[:show])
        puts "\n💿 #{@show.tracks.length} tracks found!"
    rescue => e
        puts "\n❌ Scraping failed: #{e.message}"
    end

    def setup_directories(show, base_path = Dir.pwd)
        show_date = show.date

        # Create base shows directory
        shows_dir = File.join(base_path, "shows")
        FileUtils.mkdir_p(shows_dir)
        
        # Create specific show directory
        show_dir = File.join(shows_dir, show_date)
        FileUtils.mkdir_p(show_dir)

        return show_dir
    end

    def download_show
        download_format = @args[:format]

        if download_format == "test"
          puts "Test Download, skipping"
        elsif @show.has_format(download_format)
            download_path = setup_directories(@show)
            @show.download_tracks(download_path, download_format)
        end
    end

    private

    def startup_text
        puts "\n\n"
        puts '='*52
        puts "🌹⚡️ One man gathers what another man spills... ⚡️🌹"
        puts '='*52
        puts ' '*23 + "v#{@version}"
        puts (' '*10) + ('='*32) + (' '*10)
    end
end