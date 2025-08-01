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

    def has_format(requested_format)
      @tracks[0].has_format?(requested_format)
    end

    def download_tracks(path, format)
        dl = Downloader.new(download_path, @download_format)

        @tracks.each do |track|
            track_link = track.url_for_format(format)
            dl.get(track_link)
        end
    end

    private

    def set_show_info
        show_data = Client.new.scrape_show_info(@show_link)
        
        @date = show_data[:date]
        @location = show_data[:location]
        @venue = show_data[:venue]
        @duration = show_data[:duration]
        @transferred_by = show_data[:transferred_by]
        @name = "#{show_data[:date]} - #{show_data[:venue]} - #{show_data[:location]}"
        @tracks = set_tracks(show_data[:tracks])
    end
    
    def set_tracks(track_data)
        @tracks = track_data.map { |track| Track.new(track) }
    end

    # def download_tracks(format)
    #   @tracks.each do |track|
    #     if track.has_format?(format)
    #        puts "download" 
    #     end
    #   end
    # end

end