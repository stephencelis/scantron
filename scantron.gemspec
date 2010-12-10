$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'scantron/version'

Gem::Specification.new do |s|
  s.date = "2010-11-28"

  s.name = "scantron"
  s.version = Scantron::Version::VERSION.dup
  s.summary = "Rule-based string scanning and scrubbing"
  s.description = "Rule-based string scanning and scrubbing" # FIXME

  s.files = Dir["README.rdoc", "Rakefile", "lib/**/*"]
  s.test_files = Dir["test/**/*"]

  s.add_development_dependency "rdoctest"

  s.extra_rdoc_files = %w(README.rdoc)
  s.has_rdoc = true
  s.rdoc_options = %w(--main README.rdoc)

  s.author = "Stephen Celis"
  s.email = "stephen@stephencelis.com"
  s.homepage = "http://github.com/stephencelis/scantron"
end
