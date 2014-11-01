require 'rubygems'
require 'rubygame'

module Twitterpunch
  class Sprite
    include Rubygame
    include Sprites::Sprite

    def initialize(dimensions, image, text, pop=false)
      # Invoking the base class constructor is important and yet easy to forget:
      super()

      @dimensions = dimensions
      @popped     = pop
      @text       = text
      @original   = Surface.load(image)

      if pop
        @image = @original
        @start = Time.now
        @stale = 10
      else
        @rate  = rand(35..150)
        @zoom  = rand(50..100) / 100.0
        @image = @original.zoom(@zoom)
      end

      max_width = dimensions[0] * 0.75
      if @image.width > max_width
        factor = max_width/@image.width
        @original = @original.zoom(factor)
        @image    = @image.zoom(factor)
      end

      if pop
        @left = (dimensions[0] - @image.width)  / 2
        @top  = (dimensions[1] - @image.height) / 2
      else
        @left = (dimensions[0] - @image.width ) * rand
        @top  = 0 - @image.height
      end

      @rect = @image.make_rect

      render_text
    end

    def render_text
      if @text
        text = $font.render_utf8(@text, true, Color[:black], Color[:gray])

        # for some reason, windows doesn't deal with this properly
        text.alpha = 150 unless RUBY_PLATFORM =~ /mingw|cygwin/

        # Determine the dimensions in pixels of the area used to render the text.  The
        # "topleft" of the returned rectangle is at [ 0, 0]
        rt = text.make_rect

        # Re-use the "topleft" of the rectangle to indicate where the text should
        # appear on screen ( lower left corner )
        #rt.topleft = [ 12, @image.height - rt.height - 8]
        rt.topleft = [ 0, @image.height - rt.height]

        # Copy the pixels of the rendered text to the image
        text.blit(@image, rt)
      end
    end

    # Animate this object.  "seconds_passed" contains the number of real-world
    # seconds that have passed since the last time this object was updated and is
    # therefore useful for working out how far the object should move (which
    # should be independent of the frame rate)
    def update(seconds_passed)
      if @popped
        elapsed = (Time.now - @start).to_f

        if elapsed < 1
          scale = 1 + damped_sin(elapsed, 4, 0.05)

          @image = @original.zoom(scale)
          @top  *= scale
          @left *= scale

          # We changed image size, so rebuild the rect and draw new text
          @rect = @image.make_rect
          render_text
        elsif elapsed > @stale
          @image.alpha -= 5
        end
      else
        @top += seconds_passed * @rate
      end
      @rect.topleft = [ @left, @top ]
    end

    def draw(on_surface)
      @image.blit(on_surface, @rect)
    end

    def visible
      if @popped
        @image.alpha > 0
      else
        @top < @dimensions[1]
      end
    end

    def damped_sin(input, cycles = 4, scale = 1)
      Math.sin(input * cycles * Math::PI) * (1 - input) * scale
    end

    def popped?
      return @popped
    end
  end
end
