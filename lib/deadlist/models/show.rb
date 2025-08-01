class Show
    attr_reader :name, :venue, :date, :location, :duration, :transferred_by, :tracks, :available_formats

    def initialize(download_url)
        @name = nil
        @date = nil
        @location = nil
        @venue = nil
        @duration = nil
        @transferred_by = nil
        @available_formats = []
        @tracks = []

        set_show_info(download_url)
    end

    def format_available(preferred_format)
    end

    private

    def set_show_info(download_url)
        show_data = Client.new.scrape_show_info(download_url)
        
        @date = show_data[:date]
        @location = show_data[:location]
        @venue = show_data[:venue]
        @duration = show_data[:duration]
        @transferred_by = show_data[:transferred_by]
        @name = "#{show_data[:date]} - #{show_data[:venue]} - #{show_data[:location]}"
    end
end