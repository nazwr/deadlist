# The Client class manages HTML scraping and parsing for the CLI and other classes above it. Any HTML work should be handled here.
class Client
    # Creates show_data object for helping in the creation of a new Show
    def scrape_show_info(show_link)
        doc = get_page_source(show_link)
        track_divs = doc.css('div[itemprop="track"]')

        show_data = {
            date: extract_metadata(doc, itemprop: 'datePublished'),
            location: extract_metadata(doc, label: 'Location'),
            venue: extract_metadata(doc, label: 'Venue'),
            transferred_by: extract_metadata(doc, label: 'Transferred by'),
            duration: extract_metadata(doc, label: 'Run time'),
            tracks: extract_track_data(track_divs)
        }

        return show_data
    rescue => e
        puts "\n❌ Data extraction failed: #{e.message}"
    end

    private 

    # Returns nokogiri-fied page HTML
    def get_page_source(show_link)
        return Nokogiri::HTML(HTTParty.get(show_link).body)
    rescue => e
        puts "\n❌ Scraping failed: #{e.message}"
    end

    # Handles finding of values via 'label' and 'itemprop' Xpath values
    def extract_metadata(doc, label: nil, itemprop: nil)
        if label
            # For dt/dd metadata pairs
            doc.xpath("//dt[normalize-space(text())='#{label}']/following-sibling::dd").first&.text&.strip
        elsif itemprop  
            # For itemprop attributes
            doc.xpath("//*[@itemprop='#{itemprop}']").first&.content&.strip
        end
    end

    # Hunts through track-divs for information required to create Tracks
    def extract_track_data(track_divs)
        track_divs.each_with_index.map do |div, i|
            {
                pos: i + 1, 
                name: div.css('meta[itemprop="name"]').first&.[]('content'),
                links: div.css('link[itemprop="associatedMedia"]').map { |link| link['href'] }
            }
        end
    end
end