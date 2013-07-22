$LOAD_PATH.unshift 'lib'
require "nova/version"

Gem::Specification.new do |s|
  s.name              = "nova"
  s.version           = Nova::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Software management system.  Boom."
  s.homepage          = "http://redjazz96.github.io/nova/"
  s.email             = "redjazz96@gmail.com"
  s.authors           = [ "Jeremy Rodi" ]
  s.has_rdoc          = false
  s.license           = 'MIT'

  s.files             = %w( README.md LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("spec/**/*")

#  s.executables       = %w( Nova )
  s.description       = <<desc
  Software management system.
desc

  s.add_dependency 'command-runner', '~> 0.4'
  s.add_dependency 'os', '~> 0.9'
  s.add_dependency 'packed_struct'
  s.add_dependency 'thor', '~> 0.18'
  s.add_dependency 'multi_json', '~> 1.0'

  s.add_development_dependency 'rspec'
end
