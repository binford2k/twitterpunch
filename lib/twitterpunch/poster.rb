require 'rubygems'
require 'twitter'

module Twitterpunch
  class Poster
    def initialize(config)
      @config = config
      @client = Twitter::REST::Client.new(config[:twitter])
    end

    def post(files)
      files.each do |img|

        message = "#{@config[:messages].sample} ##{@config[:hashtag]}"
        @client.update_with_media(message, File.new(File.expand_path(img)))

        soundfile = @config[:sendsound] || "#{@config[:resources]}/tweet_sent.wav"

        case RUBY_PLATFORM
        when /mingw|cygwin/
          begin
            require 'win32/sound'
            Win32::Sound.play(soundfile)
          rescue LoadError
            puts 'gem install win32-sound to enable sounds.'
          end
        when /darwin/
          system("afplay #{soundfile}")
        end

      end
    end
  end
end
