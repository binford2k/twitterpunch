require 'rubygems'
require 'colorize'
require 'logger'
require 'fileutils'

module Twitterpunch
  class Logger
    def initialize(config)
      @options = config
      @logger  = ::Logger.new(File.expand_path(config[:logfile]))

      @logger.level = config[:debug] ? ::Logger::DEBUG : ::Logger::INFO
    end

    def error(message)
      puts message.red
      @logger.error(message)
    end

    def debug(message)
      return unless @options[:debug]
      puts message.yellow
      @logger.debug(message)
    end

    def info(message)
      puts message.green unless @options[:quiet]
    end

    def log(username, message)
      @logger.info(sprintf("%15s: %s", username, message))
    end
  end
end
