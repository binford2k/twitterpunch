$:.unshift File.expand_path("../lib", __FILE__)
require 'twitterpunch'
require 'date'

Gem::Specification.new do |s|
  s.name              = "twitterpunch"
  s.version           = Twitterpunch::VERSION
  s.date              = Date.today.to_s
  s.summary           = "A simple tool to automate the posting and streaming of PhotoBooth shots over Twitter."
  s.homepage          = "http://binford2k.com"
  s.email             = "binford2k@gmail.com"
  s.authors           = ["Ben Ford"]
  s.has_rdoc          = false
  s.require_path      = "lib"
  s.executables       = %w( twitterpunch )

  s.files             = %w( LICENSE README.md )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("resources/**/*")

  s.add_dependency      "twitter"
  s.add_dependency      "oauth"
  s.add_dependency      "colorize"

  s.description       = File.read(File.join(File.dirname(__FILE__), 'README.md'))
end
