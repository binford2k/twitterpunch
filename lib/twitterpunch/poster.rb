require 'rubygems'
require 'twitter'

module Twitterpunch
  class Poster
    def initialize(config)
      @config = config
      @client = Twitter::REST::Client.new(config[:twitter])
      @sound  = @config[:sendsound] || "#{@config[:resources]}/tweet_sent.wav"
      @length = 113 - @config[:hashtag].length
    end

    def post(files)
      File.open(File.expand_path('~/.twitterpunch/queue.yaml'), 'r+') do |file|
        file.flock(File::LOCK_EX)

        queue   = YAML.load(file.read) rescue []
        queue ||= []

        files.each do |img|
          message = queue.shift || @config[:messages].sample
          message = "#{message[0..@length]} ##{@config[:hashtag]}"

          @client.update_with_media(message, File.new(File.expand_path(img)))
          chirp()
        end

        file.rewind
        file.truncate 0
        file.write(queue.to_yaml)
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
