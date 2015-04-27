Gem::Specification.new do |s|
  s.name	= 'nexpose-functions'
  s.version	= '0.0.6'
  s.summary	= "Additional Nexpose API functions."
  s.description = "Additional useful functions for use with the Nexpose API."
  s.authors	= ["Red5d"]
  s.files	= Dir['doc/**/*'] + ["lib/nexpose-functions.rb"]
  s.add_runtime_dependency 'nexpose', '>= 1.0.0'
  s.homepage    = 'http://rubygems.org/gems/nexpose-functions'
  s.license = 'MIT'
end
