require 'rubygems'
require 'oauth'
require 'yaml'

module Twitterpunch
  class Configuration

    def initialize(file)
      @configfile = file
      @config     = YAML.load_file(@configfile) rescue defaults
    end

    def authorize
      if @config.include? :twitter and @config[:twitter].include? :access_token_secret
        puts "You already have Twitter authorization."
        print "Would you like to re-authorize [y/N]? "
        return unless STDIN.gets.strip.downcase == 'y'
      end

      @config[:twitter]                   ||= {}
      @config[:twitter][:consumer_key]    ||= Twitterpunch::API_KEY
      @config[:twitter][:consumer_secret] ||= Twitterpunch::API_SECRET

      consumer = OAuth::Consumer.new(
        @config[:twitter][:consumer_key],
        @config[:twitter][:consumer_secret],
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

      access_token = request_token.get_access_token(:oauth_verifier => pin)
      @config[:twitter][:access_token]        = access_token.token
      @config[:twitter][:access_token_secret] = access_token.secret
    end

    def configure
      puts "Existing Twitter authorization will not be altered." if @config.include? :twitter
      print "Would you like to save default configuration values [y/N]? "
      return unless STDIN.gets.strip.downcase == 'y'
      @config.merge! defaults

      # This is not in defaults so it doesn't take precedence
      @config[:twitter]                   ||= {}
      @config[:twitter][:consumer_key]    ||= Twitterpunch::API_KEY
      @config[:twitter][:consumer_secret] ||= Twitterpunch::API_SECRET

      puts "Please edit #{@configfile} to configure."
      puts 'If you have your own Twitter consumer key/secret, you may replace'
      puts 'the defaults before running `twitterpunch --authorize`.'
    end

    def save
      puts @config.to_yaml
      puts
      print "Save configuration [y/N]? "
      return unless STDIN.gets.strip.downcase == 'y'
      File.open(@configfile, 'w') {|f| f.write(@config.to_yaml) }
    end

    def defaults
      puts "Generating default configuration options..."
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
        :logfile   => '~/.twitterpunch/activity.log',
      }
    end
  end
end
