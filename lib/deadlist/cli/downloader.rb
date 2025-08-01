class Downloader
    def initialize(path, format)
        @path = path
        @format = format
    end

    def get(pos, name, link)
        uri = URI.parse(link); raise ArgumentError, "Only HTTP(S) URLs allowed" unless uri.is_a?(URI::HTTP)
            
        download = uri.open
        filename = "#{@path}/#{pos} -- #{name}.#{@format}"
        IO.copy_stream(download, filename)
    rescue => e
        puts "❌ Download failed: #{e.message}"
    end
end