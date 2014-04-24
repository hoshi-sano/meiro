require "meiro/tile_manager"
require "meiro/tile_manager/binary_tile_manager"
require "meiro/tile_manager/detailed_tile_manager"
require "meiro/tile_manager/rogue_like_tile_manager"

module Meiro
  module Tile
    TYPE = {
      wall: 0,
      flat: 1,
      gate: 2,
    }

    module ModuleMethods
      def classify(tiles, type)
        case type
        when :rogue_like
          RogueLikeTileManager.classify(tiles)
        when :detail
          DetailedTileManager.classify(tiles)
        when :binary
          BinaryTileManager.classify(tiles)
        else
          tiles[1, 1]
        end
      end

      def wall
        TileManager.wall
      end

      def flat
        TileManager.flat
      end

      def gate
        TileManager.gate
      end

      def passage
        TileManager.passage
      end
    end
    extend ModuleMethods

    class BaseTile
      class << self
        def register_type(symbol)
          @type = symbol
        end

        def register_sign(sign)
          @sign = sign
        end

        def walkable(bool)
          @walkable = !!bool
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

      def walkable?
        !!self.class.instance_variable_get(:@walkable)
      end
    end

    class Wall < BaseTile
      register_type :wall
      register_sign ' '
      walkable false
    end

    class Flat < BaseTile
      register_type :flat
      register_sign '.'
      walkable true
    end

    class Gate < Flat
      register_type :gate
      register_sign '+'
      walkable true
    end

    class BinaryWall < Wall
      register_type :binary_wall
      register_sign '#'
      walkable false
    end

    class Passage < Flat
      register_type :passage
      register_sign '#'
      walkable true
    end

    # [   ]
    # [ o ]  o: target
    # [   ]
    #
    # 上の図はoを対象として、3x3の周囲9マスのマップを切り出した図を表す

    # [## ]
    # [## ]
    # [## ]
    class LWall < Wall
      register_type :l_wall
      register_sign '|'
      walkable false
    end

    # [###]
    # [###]
    # [## ]
    class LWallTCorner < Wall
      register_type :l_wall_t_corner
      register_sign '|'
      walkable false
    end

    # [## ]
    # [###]
    # [###]
    class LWallBCorner < Wall
      register_type :l_wall_b_corner
      register_sign '|'
      walkable false
    end

    # [ ##]
    # [ ##]
    # [ ##]
    class RWall < Wall
      register_type :r_wall
      register_sign '|'
      walkable false
    end

    # [###]
    # [###]
    # [ ##]
    class RWallTCorner < Wall
      register_type :r_wall_t_corner
      register_sign '|'
      walkable false
    end

    # [ ##]
    # [###]
    # [###]
    class RWallBCorner < Wall
      register_type :r_wall_t_corner
      register_sign '|'
      walkable false
    end

    # [###]
    # [###]
    # [   ]
    class TWall < Wall
      register_type :t_wall
      register_sign '-'
      walkable false
    end

    # [   ]
    # [###]
    # [###]
    class BWall < Wall
      register_type :b_wall
      register_sign '-'
      walkable false
    end

    DEFAULT_TILE_CLASS = {
      wall: Wall,
      flat: Flat,
      gate: Gate,
      passage: Passage,
      binary_wall: BinaryWall,

      # [## ]
      # [## ]
      # [## ]
      l_wall: LWall,

      # [###]
      # [###]
      # [## ]
      l_wall_t_corner: LWallTCorner,

      # [## ]
      # [###]
      # [###]
      l_wall_b_corner: LWallBCorner,

      # [ ##]
      # [ ##]
      # [ ##]
      r_wall: RWall,

      # [###]
      # [###]
      # [ ##]
      r_wall_t_corner: RWallTCorner,

      # [ ##]
      # [###]
      # [###]
      r_wall_b_corner:  RWallBCorner,

      # [###]
      # [###]
      # [   ]
      t_wall: TWall,

      # [   ]
      # [###]
      # [###]
      b_wall: BWall,
    }

    TileManager.set_tile_class(DEFAULT_TILE_CLASS)
  end
end
