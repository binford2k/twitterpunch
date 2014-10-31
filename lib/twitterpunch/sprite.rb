require 'rubygems'
require 'rubygame'

module Twitterpunch
  class Sprite
    include Rubygame
    include Sprites::Sprite

    def initialize(dimensions, image, text)
      # Invoking the base class constructor is important and yet easy to forget:
      super()

      @dimensions = dimensions

      @rate = rand(35..150)
      @zoom = rand(50..100) / 100.0

      # @image and @rect are expected by the Rubygame sprite code
      @image = Surface.load(image).zoom(@zoom)

      max_width = dimensions[0] * 0.75
      if @image.width > max_width
        @image = @image.zoom(max_width/@image.width)
      end

      @top  = 0 - @image.height
      @left = (dimensions[0] - @image.width ) * rand
      @rect = @image.make_rect

      if text
        @text = $font.render_utf8(text, true, Color[:black], Color[:gray])
        @text.alpha = 150

        # Determine the dimensions in pixels of the area used to render the text.  The
        # "topleft" of the returned rectangle is at [ 0, 0]
        rt = @text.make_rect

        # Re-use the "topleft" of the rectangle to indicate where the text should
        # appear on screen ( lower left corner )
        #rt.topleft = [ 12, @image.height - rt.height - 8]
        rt.topleft = [ 0, @image.height - rt.height]

        # Copy the pixels of the rendered text to the image
        @text.blit(@image, rt)
      end
    end

    # Animate this object.  "seconds_passed" contains the number of ( real-world)
    # seconds that have passed since the last time this object was updated and is
    # therefore useful for working out how far the object should move ( which
    # should be independent of the frame rate)
    def update(seconds_passed)
      @top += seconds_passed * @rate
      @rect.topleft = [ @left, @top ]
    end

    def draw(on_surface)
      @image.blit(on_surface, @rect)
    end

    def visible
      @top < @dimensions[1]
    end
  end
end
