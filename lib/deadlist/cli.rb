require_relative 'cli/client'
require_relative 'cli/downloader'
require_relative 'models/show'
require_relative 'models/track'
require_relative 'cli/argument_parser'
require 'fileutils'
require 'optparse'

# The CLI is the 'session' created by the main class, managing arguments passed in and housing methods for scraping and downloading shows.
class CLI
    def initialize(version, args, logger: Logger.new($stdout))
        @version = version
        @args = {}
        @show = nil
        @logger = logger

        startup_text
        parse_arguments(args)
    end

    # Creates new show object with link given populated with metadata and track details
    def create_show
        extracted_id = extract_show_id(@args[:id])
        @show = Show.new(extracted_id, @args[:format], logger: @logger)

        @logger.info "💿 #{@show.name} - #{@show.tracks.length} tracks found!"
    rescue => e
        @logger.error "❌ Scraping failed: #{e.message}"
    end

    # Validates format isn't for test, and passes directory + format arguments to the download method of a Show
    def download_show
        if @args[:format] == "test"
          @logger.info "Test Download, skipping"   
        else
            download_directory = setup_directories(@show, @args[:directory])
            @show.download_tracks(download_directory)
        end
    rescue => e
        @logger.error "❌ Download failed: #{e.message}"
    end

    private

    # Deadlist starts with some friendly text
    def startup_text
        @logger.info '='*52
        @logger.info "🌹⚡️ One man gathers what another man spills... ⚡️🌹"
        @logger.info '='*52
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
    def setup_directories(show, custom_path = nil)
        if custom_path
            # Custom path: use it directly
            base_dir = custom_path
        else
            # Default: add shows subdirectory
            base_dir = File.join(Dir.pwd, "shows")
        end

        FileUtils.mkdir_p(base_dir)

        show_dir = File.join(base_dir, show.name)
        FileUtils.mkdir_p(show_dir)

        show_dir
    rescue => e
        @logger.error "❌ Directory creation failed: #{e.message}"
    end
end
