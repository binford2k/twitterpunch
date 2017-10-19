$:.unshift File.expand_path("../lib", __FILE__)
require 'twitterpunch'
require 'date'

Gem::Specification.new do |s|
  s.name              = "twitterpunch"
  s.version           = Twitterpunch::VERSION
  s.date              = Date.today.to_s
  s.summary           = "A simple tool to automate the posting and streaming of PhotoBooth shots over Twitter."
  s.homepage          = "https://github.com/binford2k/twitterpunch"
  s.license           = 'MIT'
  s.email             = "binford2k@gmail.com"
  s.authors           = ["Ben Ford"]
  s.has_rdoc          = false
  s.require_path      = "lib"
  s.executables       = %w( twitterpunch )

  s.files             = %w( LICENSE README.md CHANGELOG.md )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("resources/**/*")
  s.files            += Dir.glob("views/**/*")
  s.files            += Dir.glob("public/**/*")

  s.add_dependency      "twitter"
  s.add_dependency      "oauth"
  s.add_dependency      "colorize"
  s.add_dependency      "rubygame"
  s.add_dependency      "sinatra"
  s.add_dependency      "rmagick"

  s.description       = File.read(File.join(File.dirname(__FILE__), 'README.md'))

  s.post_install_message = <<-desc

  ************************************************************************
  Be aware that RubyGame is BROKEN on OSX right now. You will need this
  patch before Twitterpunch will work properly:

  https://github.com/xrs1133/ruby-sdl-ffi/commit/0b721ac4659b4c08cda5aa2f418561a8a311e85b

  ************************************************************************

  desc

end
