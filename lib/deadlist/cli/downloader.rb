# A simple class to download files to a given directory. Expects details for the filename and a link.
# One Downloader should be created / show being downloaded. Downloaders can run on seperate threads for getting many hows at once.
class Downloader
    def initialize(path, format)
        @path = path
        @format = format
    end

    # Goes to a link (assuming the format is already validated), and gets the file, saving with argument names.
    def get(pos, name, link)
        uri = URI.parse(link); raise ArgumentError, "Only HTTP(S) URLs allowed" unless uri.is_a?(URI::HTTP)
            
        download = uri.open
        filename = "#{@path}/#{pos} -- #{name}.#{@format}"
        IO.copy_stream(download, filename)
    rescue => e
        puts "❌ Download failed: #{e.message}"
    end
end