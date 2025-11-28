# Object to handle Show data and the array of Track objects to be used in downloading.
class Show
    AUDIO_FORMATS = %w[mp3 flac ogg m4a].freeze

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
        download_url = dl.download_url_for_show(@show_id)

        @tracks.each do |track|
            puts "⬇️ Downloading #{track.pos} - #{track.title}..."

            dl.get(download_url, track)

            puts "⚡️ #{track.pos} - #{track.title} downloaded successfully"
        end
    end

    private

    # On initialization, show variables are extracted from the HTML data scraped by the Client.
    def set_show_info
        show_data = Client.new.query_show_info(@show_id)

        @date = show_data[:date]
        @location = show_data[:location]
        @venue = show_data[:venue]
        @duration = show_data[:duration]
        @transferred_by = show_data[:transferred_by]
        @name = "#{show_data[:date]} - #{show_data[:venue]} - #{show_data[:location]}"
        @tracks = set_tracks(show_data[:files])
        @url = "https://archive.org/metadata/#{show_data[:dir]}/"

        puts "🌹💀 Downloading #{name}"
    end
    
    # Converts track lists to Track objects
    def set_tracks(files)
        audio_files = files.select { |file| audio_file?(file) }
                            .select { |file| matches_format?(file, @format) }
                            
        if audio_files.empty?
            puts "❌ No #{@format} files found"
            return []
        end
  
        @tracks = audio_files.map.with_index(1) { |track, index| Track.new(track, index) }
    end

    def audio_file?(file)
        AUDIO_FORMATS.include?(File.extname(file["name"]).delete('.').downcase)
    end

    def matches_format?(file, format)
        File.extname(file["name"]).delete('.').downcase == format
    end
end