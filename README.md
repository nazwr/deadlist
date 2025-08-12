# deadlist
A client for interacting with Grateful Dead recordings hosted by archive.org.

Using Deadlist, you can
* Download files in any of the formats available, regardless of if they have been marked as "Stream Only".

In the future, you can use Deadlist to
* Get lists of shows by date or location
* Get lists of recordings for specific shows, including set lists and information about the upload
* Get formats a show is available in

### Arguments
* --format (required) | --format=mp3 | Format for track downloads, typically .mp3, .ogg or .flac
* --show (required) | --show={uri} | Show link from archive.org to get the link from

## How Its Structured
Deadlist scrapes audio files from archive.org pages by getting the HTML for the page, identifying .mp3 (or other audio formats) within and retrieving the files.

* DeadList::Client       -- Core scraping logic
* DeadList::CLI          -- Command line interface  
* DeadList::Track        -- Data model
* DeadList::Show         -- Data model
* DeadList::Downloader   -- Download orchestration
