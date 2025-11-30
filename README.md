# deadlist

[![Coverage Status](https://coveralls.io/repos/github/nazwr/deadlist/badge.svg?branch=main)](https://coveralls.io/github/nazwr/deadlist?branch=main)

A client for downloading Grateful Dead recordings hosted by archive.org.

With Deadlist, you can download audio files in any of the formats available, regardless of if they have been marked as "Stream Only". Files will download into a 'shows' folder in the location deadlist was executed from.

## Install
`gem install deadlist`

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

## Development

### Setup
DeadList requires Ruby >= 2.7.0. To set up the development environment:

```bash
bundle install
```

### Running Tests
DeadList uses Cucumber for BDD testing. To run the full test suite:

```bash
./script/test
```

Or run Cucumber directly:

```bash
bundle exec cucumber features/
```

To run a specific feature:

```bash
bundle exec cucumber features/argument_parsing.feature
```

### Test Coverage
Current test coverage includes:
- Argument parsing and validation
- Show metadata extraction from archive.org API
- Track filtering by audio format
- Directory creation and organization
- Download functionality
- Error handling for invalid inputs and API failures
- Version output

**49 scenarios, 192 steps, 89%+ code coverage**

### Viewing Coverage Reports
After running tests, view the coverage report locally:

```bash
open coverage/index.html  # macOS
xdg-open coverage/index.html  # Linux
```

Coverage is also automatically tracked on [Coveralls](https://coveralls.io/github/nazwr/deadlist) for all pull requests and main branch pushes. 
