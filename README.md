# deadlist
A client for interacting with Grateful Dead recordings hosted by archive.org.

Using Deadlist, you can
* Get lists of shows by date or location
* Get lists of recordings for specific shows, including set lists and information about the upload
* Download files in formats available, regardless of if they have been marked as "Stream Only".

## How It Works
Deadlist scrapes audio files from archive.org pages by getting the HTML for the page, identifying .mp3 (and other audio formats) within and retrieving the files.
