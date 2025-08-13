# Object to handle Show data and the array of Track objects to be used in downloading.
class Show
    attr_reader :name, :venue, :date, :location, :duration, :transferred_by, :tracks, :available_formats

    def initialize(show_id, format)
        @show_id = show_id
        @format = format
        @name = nil
        @date = nil
        @location = nil
        @venue = nil
        @duration = nil
        @transferred_by = nil
        @url = nil
        @tracks = nil

        set_show_info
    end

    # Initializes a Downloader and passes track details
    def download_tracks(path)
        dl = Downloader.new(path, @format)

        @tracks.each do |track|
            download_url = "https://archive.org/download/" + @show_id + "/"
            
            dl.get(download_url, track)

            puts "⚡️ #{track.pos} - #{track.title} downloaded successfully"
        end
    end

    private

    # On initialization, show variables are extracted from the HTML data scraped by the Client.
    def set_show_info
        # show_data = Client.new.scrape_show_info(@show_link)
        show_data = Client.new.query_show_info(@show_id)

        @date = show_data[:date]
        @location = show_data[:location]
        @venue = show_data[:venue]
        @duration = show_data[:duration]
        @transferred_by = show_data[:transferred_by]
        @name = "#{show_data[:date]} - #{show_data[:venue]} - #{show_data[:location]}"
        @tracks = set_tracks(show_data[:files])
        @url = "https://archive.org/metadata/" + show_data[:dir] + "/"

        puts "🌹💀 Downloading #{name}"
    end
    
    # Converts track lists to Track objects
    def set_tracks(files)
        format_length = -(@format.length)
        tracks = []

        files.each do |file_object|
          if  file_object["name"][format_length..] == @format
            tracks << file_object
          end
        end

        if tracks.length == 0
          puts "❌ Error! Could not find any files matching requested format. Please select an alternate format."
        else
            @tracks = tracks.map { |track| Track.new(track) }
        end
    end
end