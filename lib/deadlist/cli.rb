require_relative 'cli/client'
require_relative 'cli/downloader'
require_relative 'models/show'
require_relative 'models/track'
require_relative 'cli/argument_parser.rb'
require 'fileutils'
require 'optparse'

# The CLI is the 'session' created by the main class, managing arguments passed in and housing methods for scraping and downloading shows.
class CLI
    def initialize(version, args)
        @version = version
        @args = {}
        @show = nil

        startup_text
        parse_arguments(args)
    end

    # Creates new show object with link given populated with metadata and track details
    def create_show
        extracted_id = extract_show_id(@args[:id])
        @show = Show.new(extracted_id, @args[:format])

        puts "\n💿 #{@show.name} - #{@show.tracks.length} tracks found!"
    rescue => e
        puts "\n❌ Scraping failed: #{e.message}"
    end

    # Validates format isn't for test, and passes directory + format arguments to the download method of a Show
    def download_show
        if @args[:format] == "test"
          puts "Test Download, skipping"   
        else
            download_directory = setup_directories(@show)
            @show.download_tracks(download_directory)
        end
    rescue => e
        puts "\n❌ Download failed: #{e.message}"
    end

    private

    # Deadlist starts with some friendly text
    def startup_text
        puts "\n\n"
        puts '='*52
        puts "🌹⚡️ One man gathers what another man spills... ⚡️🌹"
        puts '='*52
    end

    # Reads arguments passed at the command line and maps them to an instance object
    def extract_show_id(show_input)
        if show_input.include?('archive.org/details/')
            show_input.split('/details/').last
        else
            show_input
        end
    end 
    
    def parse_arguments(args)
        @args = ArgumentParser.parse(args, @version)
    end

    # Configures directories that will be used by the downloader
    def setup_directories(show, base_path = Dir.pwd)
        # Create base shows directory
        shows_dir = File.join(base_path, "shows")
        FileUtils.mkdir_p(shows_dir)
        
        # Create specific show directory
        show_dir = File.join(shows_dir, show.name)
        FileUtils.mkdir_p(show_dir)

        return show_dir
    rescue => e
        puts "\n❌ Directory creation failed: #{e.message}"
    end
end
