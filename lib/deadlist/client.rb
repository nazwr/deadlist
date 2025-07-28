class Client
    def scrape(show_link)
        if !show_link.include? "archive.org"
            puts "\n❌ Error! Only links from archive.org are currently supported."
        else
            parsed_page_source = Nokogiri::HTML(HTTParty.get(show_link).body)
            track_divs = parsed_page_source.css('div[itemprop="track"]')

            show_info = {
                "show_name": parsed_page_source.css('span[itemprop="name"]')[0].content,
                "tracks": []
            }
            

            track_divs.each_with_index do |div, i|
                track = {
                    "pos": i+1,
                    "name": nil,
                    "links": []
                }

                for child in div.children
                    if child.name == "meta" && child.attribute_nodes[0].value == "name"
                        track[:name] = child.attribute_nodes[1].value
                    elsif child.name == "link"
                        # ❌ Why is this pushing 2x .mp3 files, vs each one seperately? 
                        track[:links] << child.attribute_nodes[1].value
                    end
                end

                show_info[:tracks] << track
            end
            binding.pry
            return show_info
        end        
            
            # if show_info["track_array"].length == 0
            #     puts "\n❌ Error! No tracks found on page. Please double check link:#{link}."
            # else
            #     binding.pry
            #     puts "\n💀 Next Up: #{show_name.to_s}"
            #     puts "-" * 50
            #     # sleep(1)
            #     puts "\n#{track_array.length} tracks found!"
            #     puts "-" * 50
                
            #     for track in track_array do
            #         download_track(track)
            #     end
            # end

        # if !link.include? "archive.org"
            #     else
            #         parsed_page_source = Nokogiri::HTML(HTTParty.get(link).body)
            #         show_name = parsed_page_source.css('span[itemprop="name"]')[0].content
            #         track_array = parsed_page_source.css('div[itemprop="track"]')

            #         if track_array.length == 0
            #             puts "\n❌ Error! No tracks found on page. Please double check link:#{link}."
            #         else
            #             puts "\n💀 Next Up: #{show_name.to_s}"
            #             puts "-" * 50
            #             # sleep(1)
            #             puts "\n#{track_array.length} tracks found!"
            #             puts "-" * 50
                        
            #             for track in track_array do
            #                 download_track(track)
            #             end
            #         end
            #     end
    end
end