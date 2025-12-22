require "mface"

module Console
  module Canvas
    class Loc
      # Creates a new Loc object, representing the location on a 2d grid, with
      # x in the horizontal direction, left to right, and y in the vertical
      # direction, top to bottom, both being 0 indexed
      def initialize(x, y)
        Mface.req_int(:x, x)
        Mface.req_int(:y, y)
        @x = x
        @y = y
      end

      attr_reader :x, :y

      # Returns a new location after adding the given vector
      def move(v_x, v_y)
        Mface.req_int(:v_x, v_x)
        Mface.req_int(:v_y, v_y)

        Console::Canvas::Loc.new(x + v_x, y + v_y)
      end

      # Moves the current location by adding the given vector
      def move!(v_x, v_y)
        Mface.req_int(:v_x, v_x)
        Mface.req_int(:v_y, v_y)

        @x += v_x
        @y += v_y
      end

      # Override the value equality operator (==)
      def ==(other)
        # Optimization: return true if it's the exact same object
        return true if equal?(other)

        # Check if the other object is an instance of the same class
        return false unless other.instance_of?(Console::Canvas::Loc)

        # Define equality based on attributes
        x == other.x && y == other.y
      end

      # Override eql? to be consistent with == for Hash lookups
      def eql?(other)
        self == other
      end

      # Override hash to ensure equal objects have the same hash code
      def hash
        [x, y].hash # Delegate hash calculation to an array of attributes
      end
    end
  end
end
