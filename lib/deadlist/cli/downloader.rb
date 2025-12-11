# A simple class to download files to a given directory. Expects details for the filename and a link.
# One Downloader should be created / show being downloaded. Downloaders can run on seperate threads for getting many hows at once.
class Downloader
    BASE_API_URL = 'https://archive.org'

    def initialize(path, format)
        @path = path
        @format = format
    end
  
    def download_url_for_show(show_id)
        "#{BASE_API_URL}/download/#{show_id}/"
    end

    # Goes to a link (assuming the format is already validated), and gets the file, saving with argument names.
    def get(root_url, track_object)
        uri = URI.parse(root_url + track_object.filename); raise ArgumentError, "Only HTTP(S) URLs allowed" unless uri.is_a?(URI::HTTP)
        download = uri.open
        sanitized_title = track_object.title.gsub('/', '-')
        filename = "#{@path}/#{track_object.pos} -- #{sanitized_title}.#{@format}"

        IO.copy_stream(download, filename)
    rescue => e
        puts "❌ Download failed for '#{track_object.title}': #{e.message}"
    end
end