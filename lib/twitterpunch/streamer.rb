require 'rubygems'
require 'yaml'
require 'twitter'
require 'net/http'

require 'twitterpunch/logger'

module Twitterpunch
  class Streamer
    def initialize(config)
      @config = config
      @viewer = config[:display]
      @client = Twitter::Streaming::Client.new(config[:twitter])
      @logger = Twitterpunch::Logger.new(config)
      @output = File.expand_path(config[:photodir])

      begin
        @handle = Twitter::REST::Client.new(config[:twitter]).current_user.screen_name
      rescue Twitter::Error => e
        puts "Cannot retrieve Twitter username."
        puts "It's likely that you're on Windows and your SSL environment isn't complete"
        puts "Download http://curl.haxx.se/ca/cacert.pem and set the environment variable"
        puts "SSL_CERT_FILE to point to it."
        puts e.message
      end

      FileUtils.mkdir_p(@output) unless File.directory?(@output)
    end

    def thread
      Thread.new do
        stream
      end
    end

    def stream
      begin
        if @config[:hashtag]
          @client.filter(:track => @config[:hashtag]) { |tweet| handle(tweet) }
        else
          @client.user { |tweet| handle(tweet) }
        end
      rescue Interrupt => e
        @logger.error "Exiting: #{e.message}"
      end
    end

    def handle(tweet)
      if tweet.is_a?(Twitter::Tweet)
        @logger.info(tweet.text)
        @logger.log(tweet.user.screen_name, tweet.text)

        content = tweet.text.gsub(/http\S*/,'').gsub(/#\S*/,'').gsub(/@#{@config[:handle]}/, '')

        if tweet.media?
          uri      = tweet.media.first.media_uri

          http     = Net::HTTP.new(uri.host, uri.port)
          request  = Net::HTTP::Get.new(uri.request_uri)
          response = http.request(request)

          image    = File.basename uri.path

          File.open("#{@output}/#{image}", 'wb') do |file|
            file.write(response.body)
          end

          unless tweet.user.screen_name == @handle
            @config[:state][image] = content
          end

          if @viewer
            @viewer.pop(image, content)
          else
            # OS X screensaver doesn't reload images dynamically. This kinda sucks.
            if RUBY_PLATFORM =~ /darwin/ and system('pgrep ScreenSaverEngine >/dev/null')
              system('osascript', '-e', 'tell application "System Events" to stop current screen saver')
              system('osascript', '-e', 'tell application "System Events" to start current screen saver')
            end
          end

        end

        unless tweet.user.screen_name == @handle
          message = "#{tweet.user.name} says #{content}"

          case RUBY_PLATFORM
          when /mingw|cygwin/
            system('cscript', "#{@config[:resources]}/say.vbs", message)
          when /darwin/
            system('say', message)
          end
        end

      end
    end

  end
end