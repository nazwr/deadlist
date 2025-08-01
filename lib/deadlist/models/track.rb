class Track
  attr_reader :pos, :name, :links

  def initialize(track_data)
    @pos = track_data[:pos]
    @name = track_data[:name]
    @links = track_data[:links]
  end

  def available_formats
    @available_formats ||= links.map { |url| File.extname(url).delete('.') }
  end
  
  def url_for_format(format)
    links.find { |url| url.end_with?(".#{format}") }
  end
  
  def has_format?(format)
    available_formats.include?(format)
  end
end