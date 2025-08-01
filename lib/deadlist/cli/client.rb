# The Client class manages HTML scraping and parsing for the CLI and other classes above it. Any HTML work should be handled here.
class Client
    
    # Creates show_data object for helping in the creation of a new Show
    def scrape_show_info(show_link)
        doc = get_page_source(show_link)

        show_data = {
            date: extract_metadata(doc, itemprop: 'datePublished'),
            location: extract_metadata(doc, label: 'Location'),
            venue: extract_metadata(doc, label: 'Venue'),
            transferred_by: extract_metadata(doc, label: 'Transferred by'),
            duration: extract_metadata(doc, label: 'Run time')
        }

        return show_data
    rescue => e
        puts "\n❌ Data extraction failed: #{e.message}"
    end

    # Function to scrape archive.org pages for track divs, isolating track names and download links in all formats to show_info object.
    # Object is returned to be handled by CLI class.  
    def scrape(show_link)
        if !show_link.include? "archive.org"
            puts "\n❌ Error! Only links from archive.org are currently supported."
        else
            # Extract relevent elements from HTML with Nokogiri to parse and process.
            parsed_page_source = get_page_source(show_link)
            track_divs = parsed_page_source.css('div[itemprop="track"]')

            # Main info object to be returned
            # ⚠️ Refactor this to use a Show class, containing Track class array. Maybe that happens after passing back to CLI.
            show = Show.new(show_link)
            # show_info = {
            #     show_name: parsed_page_source.css('span[itemprop="name"]')[0].content,
            #     tracks: []
            # }
            
            # Processing
            puts "\n⏰ Scraping links for: #{show_info[:show_name]}."

            # Iterate through track divs, pulling out name and track links from HTML content to show_info object.
            # Do as part of the Show init, create Tracks array and init function to tidy up divs
            track_divs.each_with_index do |div, i|
                track = {
                    pos: i+1,
                    name: nil,
                    links: []
                }

                for child in div.children
                    if child.name == "meta" && child.attribute_nodes[0].value == "name"
                        track[:name] = child.attribute_nodes[1].value
                    elsif child.name == "link"
                        track[:links] << child.attribute_nodes[1].value
                    end
                end

                show_info[:tracks] << track
            end

            # Validate tracks exist, and return
            if show_info[:tracks].length == 0
                puts "\n❌ Error! No tracks found on page. Please double check link."
            else   
                return show_info
            end
        end        
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
            doc.xpath("//dt[normalize-space(text())='#{label}']/following-sibling::dd")
            .first&.text&.strip
        elsif itemprop  
            # For itemprop attributes
            doc.xpath("//*[@itemprop='#{itemprop}']").first&.content&.strip
        end
    end
end