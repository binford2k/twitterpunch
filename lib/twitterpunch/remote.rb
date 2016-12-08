require 'sinatra/base'
require 'webrick'
require 'tilt/erb'
require 'open3'

class Twitterpunch::Remote < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/../../views'
  set :public_folder, File.dirname(__FILE__) + '/../../public'
  set :erb, :trim => '-'
  set :configfile,  File.expand_path('~/.twitterpunch/queue.yaml')

  configure :production, :development do
    enable :logging
    enable :sessions
  end

  get '/' do
    erb :index
  end

  get '/photo' do
    unless params.empty?
      File.open(settings.configfile, 'r+') do |file|
        file.flock(File::LOCK_EX)

        queue = YAML.load(file.read) rescue []
        queue ||= []
        queue.push params[:message]

        file.rewind
        file.truncate 0
        file.write(queue.to_yaml)
      end
    end

    photo()
  end

  not_found do
    status 404
    erb :err404
  end

  helpers do
    def photo
      begin
        stdout, status = Open3.capture2e('osascript', '-e', 'tell application "Photo Booth" to activate')
        puts stdout
        raise "Could not activate Photo Booth" unless status.success?

        stdout, status = Open3.capture2e('osascript', '-e', 'tell application "System Events" to keystroke return')
        puts stdout
        raise "Snapshot failed" unless status.success?

        'ok'
      rescue => e
        status 500
        e.message
      end
    end
  end

end
