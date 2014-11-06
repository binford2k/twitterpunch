require 'rubygems'
require 'oauth'
require 'yaml'

module Twitterpunch
  class Configuration

    def initialize(file)
      @configfile = file

      consumer = OAuth::Consumer.new(
        Twitterpunch::API_KEY,
        Twitterpunch::API_SECRET,
        {
          :site   => 'https://api.twitter.com/',
          :scheme => :header,
        })

      request_token = consumer.get_request_token

      puts 'Please authorize Twitterpunch to post to your Twitter account.'
      puts "Visit #{request_token.authorize_url} in your browser."
      # if we're on a Mac, open the page automatically
      system("open #{request_token.authorize_url} 2>/dev/null")

      print "Please enter the PIN you are given: "
      pin = STDIN.readline.chomp

      @access_token = request_token.get_access_token(:oauth_verifier => pin)
    end

    def save
      config = YAML.load_file(@configfile) rescue defaults

      config[:twitter] = {
        :consumer_key        => Twitterpunch::API_KEY,
        :consumer_secret     => Twitterpunch::API_SECRET,
        :access_token        => @access_token.token,
        :access_token_secret => @access_token.secret
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
        :viewer    => {
          :count => 5,
        },
        :hashtag   => "Twitterpunch",
        :photodir  => "~/Pictures/twitterpunch/",
        :logfile   => '~/.twitterpunch.log',
      }
    end
  end
end
