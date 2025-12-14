class ArgumentParser
  def self.parse(args, version)
    params = {}
    
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: deadlist [options]"
      opts.separator ""
      opts.separator "Required options:"
      
      opts.on("-i", "--id ID", "ID of show(s) to download (comma-separated for multiple)") do |id|
        params[:ids] = id.split(',').map(&:strip)
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

      opts.on('-q', '--quiet', 'Run silently') do
        params[:quiet] = true
      end

      opts.on('--dry-run', 'List tracks to be downloaded') do
        params[:dry_run] = true
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
    has_ids = params[:ids]&.any?
    has_format = params[:format]

    # If one is provided, both must be provided
    if !has_ids && !has_format
      puts "Error: Arguments are required for DeadList, try --help for more info"
      puts parser
      exit(1)
    elsif has_ids && !has_format
      puts "Error: --format is required when --id is provided"
      puts parser
      exit(1)
    elsif has_format && !has_ids
      puts "Error: --id is required when --format is provided"
      puts parser
      exit(1)
    end
  end
end