# Object to handle Show data and the array of Track objects to be used in downloading.
class Show
    attr_reader :name, :venue, :date, :location, :duration, :transferred_by, :tracks, :available_formats

    def initialize(download_url)
        @show_link = download_url
        @name = nil
        @date = nil
        @location = nil
        @venue = nil
        @duration = nil
        @transferred_by = nil
        @available_formats = []
        @tracks = nil

        set_show_info
    end

    # Returns whether or not a given format is available for this show
    def has_format?(requested_format)
      @tracks[0].has_format?(requested_format)
    end

    # Initializes a Downloader and passes track details
    def download_tracks(path, format)
        dl = Downloader.new(path, format)

        @tracks.each do |track|
            track_link = track.url_for_format(format)

            dl.get(track.pos, track.name, track_link)

            puts "⚡️ #{track.pos} - #{track.name} downloaded successfully"
        end
    end

    private

    # On initialization, show variables are extracted from the HTML data scraped by the Client.
    def set_show_info
        show_data = Client.new.scrape_show_info(@show_link)
        
        @date = show_data[:date]
        @location = show_data[:location]
        @venue = show_data[:venue]
        @duration = show_data[:duration]
        @transferred_by = show_data[:transferred_by]
        @name = "#{show_data[:date]} - #{show_data[:venue]} - #{show_data[:location]}"
        @tracks = set_tracks(show_data[:tracks])

        puts "🌹💀 Downloading #{name}"
    end
    
    # Converts track lists to Track objects
    def set_tracks(track_data)
        @tracks = track_data.map { |track| Track.new(track) }
    end
end