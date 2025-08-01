class Track
  attr_reader :pos, :name, :links

  def initialize(track_data)
    @pos = track_data[:pos]
    @name = track_data[:name]
    @links = track_data[:links]
  end

  # Returns formats available for a given track via the links
  def available_formats
    @available_formats ||= links.map { |url| File.extname(url).delete('.') }
  end

  # Based on the format argument, returns one link containing that format
  def url_for_format(format)
    links.find { |url| url.end_with?(".#{format}") }
  end

  # Returns boolean if a format exists for this Track
  def has_format?(format)
    available_formats.include?(format)
  end
end