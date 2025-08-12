class Track
  attr_reader :pos, :title, :filename

  def initialize(track_data)
    @pos = track_data["track"]
    @title = track_data["title"]
    @filename = track_data["name"]
  end
end