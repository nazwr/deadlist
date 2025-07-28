# deadlist
A client for interacting with Grateful Dead recordings hosted by archive.org.

Using Deadlist, you can
* Download files in any of the formats available, regardless of if they have been marked as "Stream Only".
* Set rules for downloading tracks (such as a preferred format)

In the future, you can use Deadlist to
* Get lists of shows by date or location
* Get lists of recordings for specific shows, including set lists and information about the upload

## How It Works
Deadlist scrapes audio files from archive.org pages by getting the HTML for the page, identifying .mp3 (and other audio formats) within and retrieving the files.


## Test Commands
ruby ./lib/deadlist.rb --show=https://archive.org/details/gd1977-05-09.123480.sbd.miller.flac16 --format=mp3
ruby ./lib/deadlist.rb --show=https://archive.org/details/gd1977-05-09.123480.sbd.miller.flac16 --format=test