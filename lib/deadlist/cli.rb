require_relative 'cli/client'
require_relative 'cli/downloader'
require_relative 'models/show'
require_relative 'models/track'
require_relative 'cli/argument_parser'
require 'fileutils'
require 'optparse'

# The CLI is the 'session' created by the main class, managing arguments passed in and housing methods for scraping and downloading shows.
class CLI
    attr_reader :args, :show

    def initialize(version, args, logger: Logger.new($stdout))
        @version = version
        @args = {}
        @show = nil
        @logger = logger
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end

        startup_text
        parse_arguments(args)
    end

    # Creates new show object with link given populated with metadata and track details
    def create_show
        show_id = @args[:ids].first
        extracted_id = extract_show_id(show_id)
        @show = Show.new(extracted_id, @args[:format], logger: @logger)

        @logger.info "💿 #{@show.name} - #{@show.tracks.length} tracks found!"
    rescue => e
        @logger.error "❌ Scraping failed: #{e.message}"
    end

    # Downloads show tracks or displays dry-run preview
    def download_show
        if @args[:dry_run]
            @logger.info "🔍 Dry Run: #{@show.name} will be downloaded with #{@show.tracks.count} tracks"
            @show.tracks.each do |track|
                @logger.info "  #{track.pos} - #{track.title}"
            end
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
