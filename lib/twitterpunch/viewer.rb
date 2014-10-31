require 'rubygems'
require 'rubygame'
require 'yaml'
require 'twitterpunch/sprite'

module Twitterpunch
  class Viewer
    include Rubygame

    def initialize(config)
      @config = config
      @state  = YAML.load_file(File.expand_path('~/.twitterpunch.state')) rescue {}
      srand

      if @config.has_key? :viewer
        run
      else
        puts 'Press enter to exit'
        STDIN.gets
      end
    end

    def run
      onscreen = @config[:viewer][:count] || 5

      # Set up the TrueType Font module
      TTF.setup
      point_size = 20
      $font = TTF.new("#{@config[:resources]}/Tahoma Bold.ttf", point_size)

      #@screen = Screen.open [ 640, 480]
      default_depth = 0
      maximum_resolution = Screen.get_resolution

      screen = Screen.open(maximum_resolution, default_depth, [ HWSURFACE, DOUBLEBUF, FULLSCREEN])

      screen.show_cursor = false

      clock = Clock.new
      clock.target_framerate = 60

      # Ask Clock.tick() to return ClockTicked objects instead of the number of
      # milliseconds that have passed:
      clock.enable_tick_events

      # Create a new group of sprites so that all sprites in the group may be updated
      # or drawn with a single method invocation.
      sprites = Sprites::Group.new
      Sprites::UpdateGroup.extend_object(sprites)
      onscreen.times do
        sprites << Twitterpunch::Sprite.new(maximum_resolution, *next_image)
      end

      #@background = Surface.load("background.png").zoom_to(maximum_resolution[0], maximum_resolution[1])
      # Create a background image and copy it to the screen. With no image, it's just black.
      background = Surface.new(maximum_resolution)
      background.blit(screen, [ 0, 0])

      event_queue = EventQueue.new
      event_queue.enable_new_style_events

      should_run = true
      while should_run do
        seconds_passed = clock.tick().seconds

        event_queue.each do |event|
          case event
            when Events::QuitRequested, Events::KeyReleased
              should_run = false
          end
        end

        # remove all sprites who've gone out of sight
        sprites.reject { |sprite| sprite.visible }.each do |sprite|
          sprite.kill
          sprites << Twitterpunch::Sprite.new(maximum_resolution, *next_image)
        end

        # "undraw" all of the sprites by drawing the background image at their
        # current location ( before their location has been changed by the animation)
        sprites.undraw(screen, background)

        # Give all of the sprites an opportunity to move themselves to a new location
        sprites.update(seconds_passed)

        # Draw all of the sprites
        sprites.draw(screen)

        screen.flip
      end

    end

    def next_image
      image = Dir.glob(File.expand_path("#{@config[:photodir]}/*")).sample
      text  = @config[:state][File.basename(image)]
      return image, text
    end

  end
end
