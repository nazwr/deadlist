require './lib/deadlist/models/show'
require './lib/deadlist/models/track'
require './lib/deadlist/cli/client'
require 'stringio'

# Helper to create mock show data
def mock_show_data(files)
  {
    date: "1977-05-08",
    location: "Ithaca, NY",
    venue: "Barton Hall, Cornell University",
    transferred_by: "John Doe",
    duration: "3:05:00",
    dir: "gd1977-05-08",
    files: files
  }
end

# Helper to suppress stdout
def suppress_output
  original_stdout = $stdout
  $stdout = StringIO.new
  yield
ensure
  $stdout = original_stdout
end

# Mixed format scenarios
Given('a show with mixed audio formats') do
  @files = [
    {"name" => "track01.mp3", "title" => "Bertha", "track" => "1"},
    {"name" => "track02.mp3", "title" => "Me and My Uncle", "track" => "2"},
    {"name" => "track01.flac", "title" => "Bertha", "track" => "1"},
    {"name" => "track02.flac", "title" => "Me and My Uncle", "track" => "2"},
    {"name" => "track01.ogg", "title" => "Bertha", "track" => "1"},
    {"name" => "info.txt"}
  ]
end

When('the show is initialized with format {string}') do |format|
  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_return(mock_show_data(@files))
  allow(Client).to receive(:new).and_return(client_double)

  suppress_output do
    @show = Show.new("gd1977-05-08", format)
  end
end

Then('only mp3 tracks should be included') do
  expect(@show.tracks).to all(satisfy { |track| track.filename.end_with?('.mp3') })
  expect(@show.tracks.length).to eq(2)
end

Then('non-mp3 files should be excluded') do
  filenames = @show.tracks.map(&:filename)
  expect(filenames).not_to include(match(/\.flac$/))
  expect(filenames).not_to include(match(/\.ogg$/))
  expect(filenames).not_to include(match(/\.txt$/))
end

Then('only flac tracks should be included') do
  expect(@show.tracks).to all(satisfy { |track| track.filename.end_with?('.flac') })
  expect(@show.tracks.length).to eq(2)
end

Then('non-flac files should be excluded') do
  filenames = @show.tracks.map(&:filename)
  expect(filenames).not_to include(match(/\.mp3$/))
  expect(filenames).not_to include(match(/\.ogg$/))
end

# OGG format tests
Given('a show with ogg and mp3 files') do
  @files = [
    {"name" => "track01.ogg", "title" => "Sugar Magnolia", "track" => "1"},
    {"name" => "track02.ogg", "title" => "Scarlet Begonias", "track" => "2"},
    {"name" => "track01.mp3", "title" => "Sugar Magnolia", "track" => "1"}
  ]
end

Then('only ogg tracks should be included') do
  expect(@show.tracks).to all(satisfy { |track| track.filename.end_with?('.ogg') })
  expect(@show.tracks.length).to eq(2)
end

# M4A format tests
Given('a show with m4a and flac files') do
  @files = [
    {"name" => "track01.m4a", "title" => "Eyes of the World", "track" => "1"},
    {"name" => "track02.m4a", "title" => "China Cat Sunflower", "track" => "2"},
    {"name" => "track01.flac", "title" => "Eyes of the World", "track" => "1"}
  ]
end

Then('only m4a tracks should be included') do
  expect(@show.tracks).to all(satisfy { |track| track.filename.end_with?('.m4a') })
  expect(@show.tracks.length).to eq(2)
end

# Case-insensitive matching
Given('a show with files having uppercase extensions') do
  @files = [
    {"name" => "track01.MP3", "title" => "Franklin's Tower", "track" => "1"},
    {"name" => "track02.Mp3", "title" => "Help on the Way", "track" => "2"},
    {"name" => "track03.mp3", "title" => "Slipknot!", "track" => "3"}
  ]
end

Then('tracks with .MP3 extension should be included') do
  filenames = @show.tracks.map(&:filename)
  expect(filenames).to include("track01.MP3")
end

Then('tracks with .Mp3 extension should be included') do
  filenames = @show.tracks.map(&:filename)
  expect(filenames).to include("track02.Mp3")
end

# Non-audio file exclusion
Given('a show with audio and non-audio files') do
  @files = [
    {"name" => "track01.mp3", "title" => "Truckin'", "track" => "1"},
    {"name" => "track02.mp3", "title" => "Uncle John's Band", "track" => "2"},
    {"name" => "info.txt"},
    {"name" => "setlist.txt"},
    {"name" => "cover.jpg"},
    {"name" => "artwork.png"}
  ]
end

Then('only audio files should be in tracks') do
  expect(@show.tracks.length).to eq(2)
  expect(@show.tracks).to all(satisfy { |track| track.filename.end_with?('.mp3') })
end

Then('text files should be excluded') do
  filenames = @show.tracks.map(&:filename)
  expect(filenames).not_to include(match(/\.txt$/))
end

Then('image files should be excluded') do
  filenames = @show.tracks.map(&:filename)
  expect(filenames).not_to include(match(/\.jpg$/))
  expect(filenames).not_to include(match(/\.png$/))
end

# Track attributes
Given('a show with properly formatted track data') do
  @files = [
    {"name" => "gd77-05-08d1t01.mp3", "title" => "New Minglewood Blues", "track" => "1"},
    {"name" => "gd77-05-08d1t02.mp3", "title" => "Loser", "track" => "2"}
  ]
end

When('tracks are created') do
  client_double = double('client')
  allow(client_double).to receive(:query_show_info).and_return(mock_show_data(@files))
  allow(Client).to receive(:new).and_return(client_double)

  suppress_output do
    @show = Show.new("gd1977-05-08", "mp3")
  end
  @tracks = @show.tracks
end

Then('each track should have a position') do
  expect(@tracks).to all(satisfy { |track| !track.pos.nil? })
  expect(@tracks.first.pos).to eq("1")
  expect(@tracks.last.pos).to eq("2")
end

Then('each track should have a title') do
  expect(@tracks).to all(satisfy { |track| !track.title.nil? })
  expect(@tracks.first.title).to eq("New Minglewood Blues")
  expect(@tracks.last.title).to eq("Loser")
end

Then('each track should have a filename') do
  expect(@tracks).to all(satisfy { |track| !track.filename.nil? })
  expect(@tracks.first.filename).to eq("gd77-05-08d1t01.mp3")
  expect(@tracks.last.filename).to eq("gd77-05-08d1t02.mp3")
end

# Missing track numbers
Given('a show with files missing track numbers') do
  @files = [
    {"name" => "song1.mp3", "title" => "Dark Star"},
    {"name" => "song2.mp3", "title" => "St. Stephen"},
    {"name" => "song3.mp3", "title" => "The Eleven"}
  ]
end

Then('tracks should use sequential index as position') do
  expect(@tracks.length).to eq(3)
  expect(@tracks[0].pos).to eq(1)
  expect(@tracks[1].pos).to eq(2)
  expect(@tracks[2].pos).to eq(3)
end

# Multiple tracks order
Given('a show with 5 mp3 tracks') do
  @files = [
    {"name" => "track01.mp3", "title" => "Track 1", "track" => "1"},
    {"name" => "track02.mp3", "title" => "Track 2", "track" => "2"},
    {"name" => "track03.mp3", "title" => "Track 3", "track" => "3"},
    {"name" => "track04.mp3", "title" => "Track 4", "track" => "4"},
    {"name" => "track05.mp3", "title" => "Track 5", "track" => "5"}
  ]
end

Then('there should be {int} tracks') do |count|
  expect(@show.tracks.length).to eq(count)
end

Then('tracks should be in sequential order') do
  positions = @show.tracks.map(&:pos)
  expect(positions).to eq(["1", "2", "3", "4", "5"])
end

# Unsupported formats
Given('a show with supported and unsupported audio formats') do
  @files = [
    {"name" => "track01.mp3", "title" => "Terrapin Station", "track" => "1"},
    {"name" => "track02.mp3", "title" => "Playing in the Band", "track" => "2"},
    {"name" => "track01.wav", "title" => "Terrapin Station", "track" => "1"},
    {"name" => "track02.aiff", "title" => "Playing in the Band", "track" => "2"},
    {"name" => "track03.ape", "title" => "Estimated Prophet", "track" => "3"}
  ]
end

Then('only supported format files should be included') do
  expect(@show.tracks.length).to eq(2)
  expect(@show.tracks).to all(satisfy { |track| track.filename.end_with?('.mp3') })
end

Then('unsupported audio formats should be excluded') do
  filenames = @show.tracks.map(&:filename)
  expect(filenames).not_to include(match(/\.wav$/))
  expect(filenames).not_to include(match(/\.aiff$/))
  expect(filenames).not_to include(match(/\.ape$/))
end

Given('a show with only unsupported audio formats') do
  @files = [
    {"name" => "track01.wav", "title" => "Dark Star", "track" => "1"},
    {"name" => "track02.aiff", "title" => "St. Stephen", "track" => "2"},
    {"name" => "track03.wma", "title" => "The Eleven", "track" => "3"}
  ]
end
