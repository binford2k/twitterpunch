require 'rubygems'
require 'twitter'
require 'twitterpunch/queue'
require 'tempfile'
require 'rmagick'

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

        resample(img) do |path|
          @client.update_with_media(message, File.new(path))
        end
        chirp()
      end
    end

    def resample(img)
      path = File.expand_path(img)
      size = File.size?(path)
      max  = 3000000 # max size for twitter images

      if size < max
        yield path
      else
        # since filesize grows exponentially, this will be smaller than absolutely necessary.
        ratio   = Float(max) / Float(size)
        tmpfile = Tempfile.new('twitterpunch')

        image = Magick::Image.read(path).first
        image.resize!(ratio)
        image.write(tmpfile.path)

        yield tmpfile.path

        tmpfile.close
        tmpfile.unlink

        puts "Resized image to #{Integer(ratio * 100)}%."
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
