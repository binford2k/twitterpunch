require 'sinatra/base'
require 'webrick'
require 'tilt/erb'
require 'open3'
require 'twitterpunch/queue'

class Twitterpunch::Remote < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/../../views'
  set :public_folder, File.dirname(__FILE__) + '/../../public'
  set :erb, :trim => '-'

  configure :production, :development do
    enable :logging
    enable :sessions
  end

  def initialize(app=nil)
    super(app)
    system('osascript', '-e' "tell application \"#{settings.remote[:apptitle]}\" to activate")
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
        stdout, status = Open3.capture2e('osascript', '-e', "tell application \"#{settings.remote[:apptitle]}\" to activate")
        unless status.success?
          puts stdout
          raise "Could not activate Photo Booth"
        end

        # This is kind of iffy, because it depends on having full control over the UI.
        # This will only work when the Photo Booth app actually has the foreground.
        stdout, status = Open3.capture2e('osascript', '-e', "tell application \"System Events\" to keystroke #{settings.remote[:hotkey]}")
        unless status.success?
          puts stdout
          raise "Snapshot failed"
        end

        'ok'
      rescue => e
        status 500
        e.message
      end
    end
  end

end
