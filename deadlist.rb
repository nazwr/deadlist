require 'nokogiri'
require 'open-uri'
require 'json'
require 'optparse'
require 'optparse/URI'

puts "Starting..."
sleep(1)

# Store arguements passed to file for execution. Pass arguments with --{key}={value}.
# --link={url} specifies where to get audio from archive.org
options = {}

ARGV.each do|a|
    options[:link] = a
    sleep(1)
end

# Check if a link was passed to the file. Does not validate the data in any way, just that something was given.
if options[:link] != nil
    puts "Link found..."
    
    # Fetch payload from archive.org using link argument
    puts "Fetching page from archive.org..."
    page_source = Nokogiri::HTML(open(options[:link]))
    sleep(1)

    
else
    # Error handling if no link is passed
    puts "Please pass a url when running the scraper file!"
end