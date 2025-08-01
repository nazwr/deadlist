require_relative 'cli/client'
require_relative 'cli/downloader'
require_relative 'models/show'
require_relative 'models/track'
require 'fileutils'

# The CLI is the 'session' created by the main class, managing arguments passed in and housing methods for scraping and downloading shows.
class CLI
    def initialize(version, args)
        @version = version
        @args = {}
        @show = nil

        startup_text
        parse_arguments(args)
    end

    # Reads arguments passed at the command line and maps them to an instance object
    def parse_arguments(args)
        args.each do |arg|
            key, value = arg.split('=')
            @args[key.tr('--', '').to_sym] = value
        end
    end

    # Creates new show object with link given populated with metadata and track details
    def scrape_links
        @show = Show.new(@args[:show])
        puts "\n💿 #{@show.tracks.length} tracks found!"
    rescue => e
        puts "\n❌ Scraping failed: #{e.message}"
    end

    # Validates format isn't for test, and passes directory + format arguments to the download method of a Show
    def download_show
        download_format = @args[:format]

        if download_format == "test"
          puts "Test Download, skipping"
        elsif @show.has_format?(download_format)
            download_path = setup_directories(@show)
            @show.download_tracks(download_path, download_format)
        end
    end

    private

    # Deadlist starts with some friendly text
    def startup_text
        puts "\n\n"
        puts '='*52
        puts "🌹⚡️ One man gathers what another man spills... ⚡️🌹"
        puts '='*52
    end

    # Configures directories that will be used by the downloader
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
end