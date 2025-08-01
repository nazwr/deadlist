class Downloader
    def initialize(path, format)
        @path = path
        @format = format
    end

    def get(track)
        binding.pry
        # track[:links].each do |link|
        #     next unless link.include?(@format)
            
        #     uri = URI.parse(link)
        #     raise ArgumentError, "Only HTTP(S) URLs allowed" unless uri.is_a?(URI::HTTP)
            
        #     download = uri.open
        #     filename = "#{@path}/#{track[:pos]} -- #{track[:name]}.#{@format}"
        #     IO.copy_stream(download, filename)

        #     puts "✅⚡️ #{track[:pos]} - #{track[:name]}"
            
        #     return  # Exit after first successful download
        # ensure
        #     download&.close
        # end
            
        #     puts "❌ No #{@format} format found for this track"
        # rescue => e
        #     puts "❌ Download failed: #{e.message}"
        # end
end