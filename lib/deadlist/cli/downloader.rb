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

        # Extract disc number from filename
        disc_match = track_object.filename.match(/d(\d+)t/)

        sanitized_title = track_object.title.gsub('/', '-')

        if disc_match
            # Multi-disc: use disc-track format (1-01, 2-01, etc.)
            disc_num = disc_match[1]
            padded_track = track_object.pos.rjust(2, '0')
            filename = "#{@path}/#{disc_num}-#{padded_track} -- #{sanitized_title}.#{@format}"
        else
            # Single disc: regular format
            filename = "#{@path}/#{track_object.pos} -- #{sanitized_title}.#{@format}"
        end

            IO.copy_stream(download, filename)
        true
    rescue => e
        puts "❌ Download failed for '#{track_object.title}': #{e.message}"
        false
    end
end