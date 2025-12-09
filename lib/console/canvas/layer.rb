# frozen_string_literal: true

module Console
  module Canvas
    class Layer
      # Creates a new layer object
      # size_x: size of the layer on screen moving left to right
      # size_y: size of the layer on screen moving top to bottom
      # def_char: the default character to use
      # @grid: 2d array used to store the contents of the layer
      def initialize(size_x: 0, size_y: 0, def_char: " ")
        force_int("size_x", size_x)
        force_int("size_y", size_y)
        force_char("def_char", def_char)

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

      private

      # Raises an error if the specified value is not an Integer
      # arg_name: name of the argument passed into the original method
      # value: the value of the argument passed into the original method
      def force_int(arg_name, value)
        unless value.is_a? Integer
          raise ArgumentError, "#{arg_name}, (#{value}), must be an Integer"
        end
      end

      # Raises an error if the specified value is not a single character
      # arg_name: name of the argument passed into the original method
      # value: the value of the argument passed into the original method
      def force_char(arg_name, value)
        unless value.is_a? String
          raise ArgumentError, "#{arg_name}, (#{value}), must be a String"
        end

        unless value.length == 1
          raise ArgumentError, "#{arg_name}, (#{value}), must be a single character"
        end
      end
    end
  end
end
