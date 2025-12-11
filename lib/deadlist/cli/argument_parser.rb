class ArgumentParser
  def self.parse(args, version)
    params = {}
    
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: deadlist [options]"
      opts.separator ""
      opts.separator "Required options:"
      
      opts.on("-i", "--id ID", "ID of show to download") do |id|
        params[:id] = id
      end
      
      opts.on("-f", "--format FORMAT", "Format to download (mp3, flac, ogg)") do |format|
        params[:format] = format.downcase
      end
      
      opts.separator ""
      opts.separator "Other options:"
      
      opts.on("-d", "--directory PATH", "Directory to save show(s) to. Will default to /shows/ in the execution directory") do |dir|
        params[:directory] = dir
      end

      opts.on("-h", "--help", "Show this help") do
        puts opts
        exit
      end
      
      opts.on("-v", "--version", "Show version") do
        puts "deadlist v#{version}"
        exit
      end
    end
    
    parser.parse!(args)
    validate_required_params!(params, parser)
    params
  rescue OptionParser::InvalidOption => e
    puts "Error: #{e.message}"
    puts parser
    exit(1)
  end

  private

  def self.validate_required_params!(params, parser)
    missing = []
    missing << "--id" unless params[:id]
    missing << "--format" unless params[:format]
    
    unless missing.empty?
      puts "Error: Missing required arguments: #{missing.join(', ')}"
      puts parser
      exit(1)
    end
  end
end