require 'rubygems'
require 'twitter'
require 'twitterpunch/queue'

module Twitterpunch
  class Poster
    def initialize(config)
      @config = config
      @client = Twitter::REST::Client.new(config[:twitter])
      @sound  = @config[:sendsound] || "#{@config[:resources]}/tweet_sent.wav"
      @length = 113 - @config[:hashtag].length
      @queue  = Twitterpunch::Queue.new(config)
    end

    def post(files)
      files.each do |img|
        message = @queue.pop || @config[:messages].sample
        message = "#{message[0..@length]} ##{@config[:hashtag]}"

        @client.update_with_media(message, File.new(File.expand_path(img)))
        chirp()
      end
    end

    def chirp
      case RUBY_PLATFORM
      when /mingw|cygwin/
        begin
          require 'win32/sound'
          Win32::Sound.play(@sound)
        rescue LoadError
          puts 'gem install win32-sound to enable sounds.'
        end
      when /darwin/
        system("afplay #{@sound}")
      end
    end

  end
end
