module Meiro
  module Tile
    TYPE = {
      wall: 0,
      flat: 1,
      gate: 2,
    }

    class BaseTile
      class << self
        def register_type(symbol)
          @type = symbol
        end

        def register_sign(sign)
          @sign = sign
        end
      end

      def type
        self.class.instance_variable_get(:@type)
      end

      def type_is?(symbol)
        self.type == symbol
      end

      def sign
        self.class.instance_variable_get(:@sign)
      end

      def to_s
        sign
      end
    end

    class Wall < BaseTile
      register_type :wall
      register_sign '#'
    end

    class Flat < BaseTile
      register_type :flat
      register_sign '.'
    end

    class Gate < Flat
      register_type :gate
      register_sign '+'
    end
  end
end
