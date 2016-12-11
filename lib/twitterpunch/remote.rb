require 'sinatra/base'
require 'webrick'
require 'tilt/erb'
require 'open3'
require 'twitterpunch/queue'

class Twitterpunch::Remote < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/../../views'
  set :public_folder, File.dirname(__FILE__) + '/../../public'
  set :erb, :trim => '-'
  set :configfile,  File.expand_path('~/.twitterpunch/queue.yaml')

  configure :production, :development do
    enable :logging
    enable :sessions
    system('osascript', '-e' 'tell application "Photo Booth" to activate')
  end

  get '/' do
    erb :index
  end

  get '/photo' do
    settings.queue.push(params[:message]) unless params.empty?
    photo()
  end

  not_found do
    status 404
  end

  helpers do
    def photo
      begin
        stdout, status = Open3.capture2e('osascript', '-e', 'tell application "Photo Booth" to activate')
        puts stdout
        raise "Could not activate Photo Booth" unless status.success?

        # This is kind of iffy, because it depends on having full control over the UI.
        # This will only work when Photo Booth actually has the foreground.
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
