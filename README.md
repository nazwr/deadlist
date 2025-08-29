# deadlist
A client for downloading Grateful Dead recordings hosted by archive.org.

With Deadlist, you can download audio files in any of the formats available, regardless of if they have been marked as "Stream Only". Files will download into a 'shows' folder in the location deadlist was executed from.

## Install
As a gem:
`gem install deadlist`

This repository could also be cloned and run directly.
  * Clone repository: `git clone https://github.com/nazwr/deadlist.git`
  * Move into repo: `cd ./deadlist`
  * Run DeadList with: `./lib/deadlist.rb -f [format] -i [identifier]`

## Usage
### Download a show in mp3
`deadlist -f mp3 -i gd1977-05-09.123480.sbd.miller.flac16`

### Full list of arguments

| Name              | Arguments     | Usage                                                      |
| ----------------- | ------------- | ---------------------------------------------------------- |
| Format (required) | -f, --format  | Format for track downloads, typically .mp3, .ogg or .flac  |
| ID (required)     | -i, --id      | Identifier of show to be downloaded.                       |
| Help              | -h, --help    | Show help documentation                                    |
| Version           | -v, --version | Prints version of DeadList being run                       |


## How do I find the identifier of the show I want to download?
* IDs can be found in the details section at the bottom of the page (just above reviews), alongside 'Lineage' and 'Transferred by' etc.
* ID's can also be found in the web-address of the archive.org page, just after `/details/`
  * Given a show `https://archive.org/details/gd1977-05-09.123480.sbd.miller.flac16`
  * Then the identifier is `gd1977-05-09.123480.sbd.miller.flac16` 
