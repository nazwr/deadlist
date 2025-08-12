# The Client class manages HTML scraping and parsing for the CLI and other classes above it. Any HTML work should be handled here.
class Client
    # RESTful query logic
    def query_show_info(show_id)
        url = 'https://archive.org/metadata/' + show_id
        response = HTTParty.get(url)

        show_data = {
            date: response["metadata"]["date"],
            location: response["metadata"]["coverage"],
            venue: response["metadata"]["venue"],
            transferred_by: response["metadata"]["transferer"],
            duration: response["metadata"]["runtime"],
            dir: response["metadata"]["identifier"],
            files: response["files"]
        }

        return show_data
    rescue => e
        puts "\n❌ Query failed: #{e.message}"
    end
end