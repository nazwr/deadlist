class Track
  attr_reader :pos, :title, :filename

  def initialize(track_data, index)
    @pos = track_data["track"] || index
    @title = track_data["title"]
    @filename = track_data["name"]
  end
end