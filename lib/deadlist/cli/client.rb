
class Client
    # Function to scrape archive.org pages for track divs, isolating track names and download links in all formats to show_info object.
    # Object is returned to be handled by CLI class.
    def scrape(show_link)
        if !show_link.include? "archive.org"
            puts "\n❌ Error! Only links from archive.org are currently supported."
        else
            # Extract relevent elements from HTML with Nokogiri to parse and process.
            parsed_page_source = Nokogiri::HTML(HTTParty.get(show_link).body)
            track_divs = parsed_page_source.css('div[itemprop="track"]')

            # Main info object to be returned
            # ⚠️ Refactor this to use a Show class, containing Track class array. Maybe that happens after passing back to CLI.
            show_info = {
                show_name: parsed_page_source.css('span[itemprop="name"]')[0].content,
                tracks: []
            }
            
            # Processing
            puts "\n⏰ Scraping links for: #{show_info[:show_name]}."

            # Iterate through track divs, pulling out name and track links from HTML content to show_info object.
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
end