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

        system("afplay #{@config[:sendsound]}")
      end
    end
  end
end
