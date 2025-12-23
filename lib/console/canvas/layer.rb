# frozen_string_literal: true

require "mface"
require "io/console"

module Console
  module Canvas
    class Layer
      MAX_WIDTH = IO.console.winsize[1]
      DEFAULT_CHAR = " "

      # Creates a new layer object
      # size_x: size of the layer on screen moving left to right
      # size_y: size of the layer on screen moving top to bottom
      # def_char: the default character to use
      #
      # @grid: 2d array used to store the contents of the layer
      # @def_char: var for storing def_char in case it's modified
      def initialize(size_x = 0, size_y = 0, def_char = DEFAULT_CHAR)
        Mface.req_int(:size_x, size_x)
        Mface.req_int(:size_y, size_y)
        Mface.req_char(:def_char, def_char)

        @grid = Array.new(size_y) { Array.new(size_x) { def_char } }
        @def_char = def_char
      end

      # Get the size of the @grid in the x direction, left to right
      # NOTE: We assume that all rows are the same length, and that we can use
      # the length of the first row.
      def size_x
        (@grid.count > 0) ? @grid[0].count : 0
      end

      # Get the size of the @grid in the y direction, top to bottom
      def size_y
        @grid.count
      end

      # Returns true if there is no meaningful content in @grid
      def empty?
        size_x == 0 || size_y == 0
      end

      # Inserts the given str at the given location in the @grid
      def insert_str(str, loc = Canvas::Loc.new)
        unless sufficient_for_str?(str, loc)
          expand_for_str(str, loc)
        end

        @grid[loc.y][loc.x..(loc.x + str.length - 1)] = str.chars
      end

      def sufficient_for_str?(str, loc = Canvas::Loc.new)
        return false if empty?

        start_loc = Canvas::Loc.new(loc.x, loc.y)
        end_loc = Canvas::Loc.new(start_loc.x + str.length - 1, loc.y)

        return false unless size_y > end_loc.y
        return false unless size_x > end_loc.x
        true
      end

      def expand_for_str(str, loc = Canvas::Loc.new)
        start_loc = Canvas::Loc.new(loc.x, loc.y)
        end_loc = Canvas::Loc.new(start_loc.x + str.length - 1, start_loc.y)

        # Make sure end_loc is still on screen
        raise Canvas::Error, "location off screen" if loc_off_screen?(end_loc)

        if end_loc.y >= size_y
          diff = end_loc.y - size_y
          needed = diff + 1
          add_row(needed)
        end

        if end_loc.x >= size_x
          diff = end_loc.x - size_x
          needed = diff + 1
          add_col(needed)
        end
      end

      def add_row(num = 1)
        num.times { @grid << Array.new(size_x) { DEFAULT_CHAR } }
      end

      def add_col(num = 1)
        @grid.map! { |row| row + Array.new(num) { DEFAULT_CHAR } }
      end

      private

      def loc_off_screen?(loc)
        count_at_loc = loc.x + 1
        count_at_loc > MAX_WIDTH
      end
    end
  end
end
