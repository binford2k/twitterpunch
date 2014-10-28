require 'rubygems'
require 'yaml'
require 'twitter'
require "net/http"

require 'twitterpunch/logger'

module Twitterpunch
  class Streamer
    def initialize(config)
      @config = config
      @client = Twitter::Streaming::Client.new(config[:twitter])
      @logger = Twitterpunch::Logger.new(config)
      @output = File.expand_path(config[:photodir])

      FileUtils.mkdir_p(@output) unless File.directory?(@output)
    end

    def stream
      begin
        @client.filter(:track => @config[:hashtag]) do |tweet|
          if tweet.is_a?(Twitter::Tweet)
            @logger.info(tweet.text)
            @logger.log(tweet.user.screen_name, tweet.text)


            unless tweet.user.screen_name == @config[:handle]
              message = "#{tweet.user.name} says #{tweet.text.gsub(/ http\S*/,'').gsub(/#\S*/,'')}"

              case RUBY_PLATFORM
              when /mingw|cygwin/
                system('cscript', "#{@config[:resources]}/say.vbs", message)
              when /darwin/
                system('say', message)
              end
            end

            if tweet.media?
              uri      = tweet.media.first.media_uri

              http     = Net::HTTP.new(uri.host, uri.port)
              request  = Net::HTTP::Get.new(uri.request_uri)
              response = http.request(request)

              File.open("#{@output}/#{File.basename uri.path}", 'wb') do |file|
                file.write(response.body)
              end

              # OS X screensaver doesn't reload images dynamically. This kinda sucks.
              if RUBY_PLATFORM =~ /darwin/
                system('osascript', '-e', 'tell application "System Events" to stop current screen saver')
                system('osascript', '-e', 'tell application "System Events" to start current screen saver')
              end
            end
          end
        end
      rescue Interrupt => e
        @logger.error "Exiting: #{e.message}"
      end
    end

  end
end