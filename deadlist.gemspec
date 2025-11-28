Gem::Specification.new do |s|
  s.name        = "deadlist"
  s.version     = "1.1.0" # Reference constant
  s.summary     = "Download Grateful Dead shows from archive.org"
  s.description = "A Ruby gem for downloading Grateful Dead concert recordings from the Internet Archive"
  s.authors     = ["nazwr"]
  s.email       = "nathan@azotiwright.com"
  s.files       = Dir["lib/**/*.rb"]  # Include all lib files
  s.executables = ["deadlist"]  # If you want CLI executable
  s.homepage    = "https://github.com/nazwr/deadlist"
  s.license     = "MIT"
  s.required_ruby_version = '>= 2.7.0'
  
  # Add dependencies
  s.add_dependency 'httparty', '~> 0.21'
end