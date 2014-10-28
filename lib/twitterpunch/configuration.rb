require 'rubygems'
require 'oauth'
require 'yaml'

module Twitterpunch
  class Configuration

    def initialize(file)
      @configfile = file

      puts "Set up your application at https://twitter.com/apps/"
      puts "then enter your 'Consumer key' and 'Consumer secret':"

      print "Consumer key: "
      @consumer_key = STDIN.readline.chomp
      print "Consumer secret: "
      @consumer_secret = STDIN.readline.chomp

      consumer = OAuth::Consumer.new(
        @consumer_key,
        @consumer_secret,
        {
          :site   => 'https://api.twitter.com/',
          :scheme => :header,
        })

      request_token = consumer.get_request_token

      puts "Visit #{request_token.authorize_url} in your browser to authorize the app"
      # if we're on a Mac, open the page automatically
      system("open #{request_token.authorize_url} 2>/dev/null")

      print "Please enter the PIN you are given: "
      pin = STDIN.readline.chomp

      @access_token = request_token.get_access_token(:oauth_verifier => pin)
    end

    def save
      config = YAML.load_file(@configfile) rescue defaults

      config[:twitter] = {
        :consumer_key        => "#{@consumer_key}",
        :consumer_secret     => "#{@consumer_secret}",
        :access_token        => "#{@access_token.token}",
        :access_token_secret => "#{@access_token.secret}"
      }

      File.open(@configfile, 'w') {|f| f.write(config.to_yaml) }
    end

    def defaults
      {
        :messages => [
          "Hello there",
          "I'm a posting fool",
          "minimally viable product"
        ],
        :hashtag   => "BestHalloweenPartyEver",
        :handle    => "fassford",
        :photodir  => "~/Pictures/twitterpunch/",
        :logfile   => '/var/log/twitterpunch',
        :sendsound => "/System/Library/PrivateFrameworks/ToneLibrary.framework/Versions/A/Resources/AlertTones/tweet_sent.caf",
      }
    end
  end
end
