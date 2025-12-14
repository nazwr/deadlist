# deadlist

[![Coverage Status](https://coveralls.io/repos/github/nazwr/deadlist/badge.svg?branch=main)](https://coveralls.io/github/nazwr/deadlist?branch=main)

A Ruby client for downloading Grateful Dead recordings hosted by archive.org.

With Deadlist, you can download audio files in any of the formats available, regardless of if they have been marked as "Stream Only". Files will download into a 'shows' folder in the current directory by default, or to a custom location using the `--directory` flag.

## Install
`gem install deadlist`

## Usage
### Download a show in mp3
`deadlist -f mp3 -i gd1977-05-09.123480.sbd.miller.flac16`

### Download multiple shows at once
`deadlist -f mp3 -i gd1977-05-08,gd1977-05-09,gd1978-05-05`

### Full list of arguments

| Name              | Arguments       | Usage                                                      |
| ----------------- | --------------- | ---------------------------------------------------------- |
| Format (required) | -f, --format    | Format for track downloads, typically .mp3, .ogg or .flac  |
| ID (required)     | -i, --id        | Show identifier(s) - single or comma-separated for multiple shows |
| Directory         | -d, --directory | Custom download location. Defaults to ./shows              |
| Help              | -h, --help      | Show help documentation                                    |
| Version           | -v, --version   | Show version of DeadList                                   |
| Quiet             | -q, --quiet     | Suppresses logger output for run                           |
| Dry Run           | --dry-run       | Preview mode - shows what would be downloaded without downloading |


### Advanced Usage
#### Custom download location
`deadlist -f mp3 -i gd1977-05-09.123480.sbd.miller.flac16 -d /path/to/downloads`

#### Preview before downloading
`deadlist -f mp3 -i gd1977-05-08 --dry-run`

#### Download multiple shows quietly
`deadlist -f mp3 -i gd1977-05-08,gd1978-05-05,gd1979-05-05 --quiet`

## Features
- **Batch downloads**: Download multiple shows at once with comma-separated IDs
- **Stream-only bypass**: Download files marked as "Stream Only" on archive.org
- **Multi-disc support**: Automatically handles shows split into multiple discs/sets with proper track numbering (e.g., `1-01`, `2-01`)
- **Smart file naming**: Sanitizes problematic characters (like slashes) in song titles
- **Download tracking**: Shows progress with "Downloaded X/Y tracks successfully!" summary and "Processing show 1/3" for batches
- **Graceful error handling**: If a show isn't available in the requested format, it's skipped and others continue
- **Preview mode**: Use `--dry-run` to see what would be downloaded without actually downloading
- **Quiet mode**: Use `--quiet` to suppress informational output, showing only errors
- **Customizable output**: Specify download location or use default `./shows/` directory

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
Current test coverage includes core functionality of DeadList and should be run when updating or adding new features.

### Viewing Coverage Reports
After running tests, view the coverage report locally:

```bash
open coverage/index.html  # macOS
xdg-open coverage/index.html  # Linux
```

Coverage is also automatically tracked on [Coveralls](https://coveralls.io/github/nazwr/deadlist) for all pull requests and main branch pushes.

## Releasing

### Working on a New Release
When working on a new release, its best to have a release/x.x.x branch to work from as releases should build from main. Feature branches should be worked on under the release branch until they are ready to be released through the process described below.

### Creating a New Release

To publish a new version of DeadList to RubyGems:

1. **Update the version** in `lib/deadlist/version.rb`:
   ```ruby
   class DeadList
     VERSION = '1.2.0'  # Update to your new version
   end
   ```

2. **Commit and push your changes**:
   ```bash
   git add lib/deadlist/version.rb
   git commit -m "Bump version to 1.2.0"
   git push origin main
   ```

3. **Create and push a version tag**:
   ```bash
   git tag v1.2.0
   git push origin v1.2.0
   ```

4. **GitHub Actions automatically handles the rest**:
   - Builds the gem with `gem build deadlist.gemspec`
   - Publishes to RubyGems using your `RUBYGEMS_API_KEY` secret
   - The new version will be available via `gem install deadlist`

**Note:** The tag must start with `v` (e.g., `v1.2.0`) to trigger the publish workflow. 
