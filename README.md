# deadlist
A client for downloading Grateful Dead recordings hosted by archive.org.

> [!WARNING]  
> 🚧 DeadList is very much a work in progress!
> Check back soon

## Using Deadlist, you can
* Download audio files in any of the formats available, regardless of if they have been marked as "Stream Only".

## How to install
* DeadList is available as a gem! Run `gem install deadlist` to get the most recent version available
* This repository can be cloned and run directly.
  * Clone repository: `git clone https://github.com/nazwr/deadlist.git`
  * Move into parent directory: `cd ./deadlist`
  * Run DeadList with: `./lib/deadlist.rb -f [format] -i [identifier]`

## Arguments
| Name              | Arguments     | Usage                                                      |
| ----------------- | ------------- | ---------------------------------------------------------- |
| Format (required) | -f, --format  | Format for track downloads, typically .mp3, .ogg or .flac  |
| ID (required)     | -i, --id      | Identifier of show to be downloaded.                       |
| Help              | -h, --help    | Show help documentation                                    |
| Version           | -v, --version | Prints version of DeadList being run                       |


## How do I find the identifier of the show I want to download?
* IDs can be found in the details section at the bottom of the page (just about reviews), alongside 'Lineage' and 'Transferred by' etc.
* ID's can also be found in the web-address of the archive.org page, just after `/details/`
  * Given a show https://archive.org/details/gd1977-05-09.123480.sbd.miller.flac16
  * Then the identifier would be `gd1977-05-09.123480.sbd.miller.flac16` 

## In the future, you should be able to use Deadlist to
* Get formats a show is available in
* Get lists of uploads by date
* Get setlists for a specific date
* Get lists of recordings for specific shows, including set lists and information about the upload, transferrer etc.
