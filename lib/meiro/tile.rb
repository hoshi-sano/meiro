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

    ###### ここからrogue_like Tile ###################################

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

    ###### ここまでrogue_like Tile ###################################

    ###### ここからdetailed Tile #####################################

    # 以降に出現する数字は以下のように定義している。
    #
    # 123
    # 456
    # 789
    #
    # 1つの壁を上のような3x3で考えた時、直上のタイルが床(またはそれに順
    # ずる壁以外)のタイルであった場合に、2が欠けている(Chipped2)、と表
    # 現する。同様に、左下と右下が床のタイルであった場合に、7と9が欠け
    # ている(Chipped79)、と表現する。

    # [ ##]
    # [###]
    # [###]
    class Chipped1 < Wall
      register_type :chipped_1
      register_sign '|'
      walkable false
    end

    # [# #] [  #] [#  ] [   ]
    # [###] [###] [###] [###]
    # [###] [###] [###] [###]
    class Chipped2 < Wall
      register_type :chipped_2
      register_sign '-'
      walkable false
    end

    # [## ]
    # [###]
    # [###]
    class Chipped3 < Wall
      register_type :chipped_3
      register_sign '|'
      walkable false
    end

    # [###] [ ##] [###] [ ##]
    # [ ##] [ ##] [ ##] [ ##]
    # [###] [###] [ ##] [ ##]
    class Chipped4 < Wall
      register_type :chipped_4
      register_sign '|'
      walkable false
    end

    # [###] [## ] [###] [## ]
    # [## ] [## ] [## ] [## ]
    # [###] [###] [## ] [## ]
    class Chipped6 < Wall
      register_type :chipped_6
      register_sign '|'
      walkable false
    end

    # [###]
    # [###]
    # [ ##]
    class Chipped7 < Wall
      register_type :chipped_7
      register_sign '|'
      walkable false
    end

    # [###] [###] [###] [###]
    # [###] [###] [###] [###]
    # [# #] [#  ] [  #] [   ]
    class Chipped8 < Wall
      register_type :chipped_8
      register_sign '-'
      walkable false
    end

    # [###]
    # [###]
    # [## ]
    class Chipped9 < Wall
      register_type :chipped_9
      register_sign '|'
      walkable false
    end

    # [ # ]
    # [###]
    # [###]
    class Chipped13 < Wall
      register_type :chipped_13
      register_sign ' '
      walkable false
    end

    # [ ##] [ ##] [ # ] [ # ]
    # [## ] [## ] [## ] [## ]
    # [###] [## ] [###] [## ]
    class Chipped16 < Wall
      register_type :chipped_16
      register_sign ' '
      walkable false
    end

    # [ ##]
    # [###]
    # [ ##]
    class Chipped17 < Wall
      register_type :chipped_17
      register_sign ' '
      walkable false
    end

    # [ ##] [ ##] [ ##] [ ##]
    # [###] [###] [###] [###]
    # [# #] [#  ] [  #] [   ]
    class Chipped18 < Wall
      register_type :chipped_18
      register_sign ' '
      walkable false
    end

    # [ ##]
    # [###]
    # [## ]
    class Chipped19 < Wall
      register_type :chipped_19
      register_sign ' '
      walkable false
    end

    # [# #] [#  ] [  #] [   ]
    # [ ##] [ ##] [ ##] [ ##]
    # [###] [###] [###] [###]
    #
    # [# #] [#  ] [  #] [   ]
    # [ ##] [ ##] [ ##] [ ##]
    # [ ##] [ ##] [ ##] [ ##]
    class Chipped24 < Wall
      register_type :chipped_24
      register_sign ' '
      walkable false
    end

    # [# #] [#  ] [  #] [   ]
    # [## ] [## ] [## ] [## ]
    # [###] [###] [###] [###]
    #
    # [# #] [#  ] [  #] [   ]
    # [## ] [## ] [## ] [## ]
    # [## ] [## ] [## ] [## ]
    class Chipped26 < Wall
      register_type :chipped_26
      register_sign ' '
      walkable false
    end

    # [# #] [  #] [#  ] [   ]
    # [###] [###] [###] [###]
    # [ ##] [ ##] [ ##] [ ##]
    class Chipped27 < Wall
      register_type :chipped_27
      register_sign ' '
      walkable false
    end

    # [# #] [  #] [#  ] [   ]
    # [###] [###] [###] [###]
    # [# #] [# #] [# #] [# #]
    #
    # [# #] [  #] [#  ] [   ]
    # [###] [###] [###] [###]
    # [#  ] [#  ] [#  ] [#  ]
    #
    # [# #] [  #] [#  ] [   ]
    # [###] [###] [###] [###]
    # [  #] [  #] [  #] [  #]
    #
    # [# #] [  #] [#  ] [   ]
    # [###] [###] [###] [###]
    # [   ] [   ] [   ] [   ]
    class Chipped28 < Wall
      register_type :chipped_28
      register_sign ' '
      walkable false
    end

    # [# #] [  #] [#  ] [   ]
    # [###] [###] [###] [###]
    # [## ] [## ] [## ] [## ]
    class Chipped29 < Wall
      register_type :chipped_29
      register_sign ' '
      walkable false
    end

    # [## ] [ # ] [## ] [ # ]
    # [ ##] [ ##] [ ##] [ ##]
    # [###] [###] [ ##] [ ##]
    class Chipped34 < Wall
      register_type :chipped_34
      register_sign ' '
      walkable false
    end

    # [## ]
    # [###]
    # [ ##]
    class Chipped37 < Wall
      register_type :chipped_37
      register_sign ' '
      walkable false
    end

    # [## ] [## ] [## ] [## ]
    # [###] [###] [###] [###]
    # [# #] [  #] [#  ] [   ]
    class Chipped38 < Wall
      register_type :chipped_38
      register_sign ' '
      walkable false
    end

    # [## ]
    # [###]
    # [## ]
    class Chipped39 < Wall
      register_type :chipped_39
      register_sign ' '
      walkable false
    end

    # [###] [ ##] [###] [ ##]
    # [ # ] [ # ] [ # ] [ # ]
    # [###] [###] [ ##] [ ##]
    #
    # [## ] [ # ] [## ] [ # ]
    # [ # ] [ # ] [ # ] [ # ]
    # [###] [###] [ ##] [ ##]
    #
    # [###] [ ##] [###] [ ##]
    # [ # ] [ # ] [ # ] [ # ]
    # [## ] [## ] [ # ] [ # ]
    #
    # [## ] [ # ] [## ] [ # ]
    # [ # ] [ # ] [ # ] [ # ]
    # [## ] [## ] [ # ] [ # ]
    class Chipped46 < Wall
      register_type :chipped_46
      register_sign ' '
      walkable false
    end

    # [###] [ ##] [###] [ ##]
    # [ ##] [ ##] [ ##] [ ##]
    # [# #] [# #] [  #] [  #]
    #
    # [###] [ ##] [###] [ ##]
    # [ ##] [ ##] [ ##] [ ##]
    # [#  ] [#  ] [   ] [   ]
    class Chipped48 < Wall
      register_type :chipped_48
      register_sign ' '
      walkable false
    end

    # [###] [ ##] [###] [ ##]
    # [ ##] [ ##] [ ##] [ ##]
    # [## ] [## ] [ # ] [ # ]
    class Chipped49 < Wall
      register_type :chipped_49
      register_sign ' '
      walkable false
    end

    # [###] [## ] [###] [## ]
    # [## ] [## ] [## ] [## ]
    # [ ##] [ ##] [ # ] [ # ]
    class Chipped67 < Wall
      register_type :chipped_67
      register_sign ' '
      walkable false
    end

    # [###] [## ] [###] [## ]
    # [## ] [## ] [## ] [## ]
    # [# #] [# #] [#  ] [#  ]
    #
    # [###] [## ] [###] [## ]
    # [## ] [## ] [## ] [## ]
    # [  #] [  #] [   ] [   ]
    class Chipped68 < Wall
      register_type :chipped_68
      register_sign ' '
      walkable false
    end

    # [###]
    # [###]
    # [ # ]
    class Chipped79 < Wall
      register_type :chipped_79
      register_sign ' '
      walkable false
    end

    # [ # ]
    # [###]
    # [ ##]
    class Chipped137 < Wall
      register_type :chipped_137
      register_sign ' '
      walkable false
    end

    # [ # ] [ # ] [ # ] [ # ]
    # [###] [###] [###] [###]
    # [# #] [  #] [#  ] [   ]
    class Chipped138 < Wall
      register_type :chipped_138
      register_sign ' '
      walkable false
    end

    # [ # ]
    # [###]
    # [## ]
    class Chipped139 < Wall
      register_type :chipped_139
      register_sign ' '
      walkable false
    end

    # [ ##] [ # ] [ ##] [ # ]
    # [## ] [## ] [## ] [## ]
    # [ ##] [ ##] [ # ] [ # ]
    class Chipped167 < Wall
      register_type :chipped_167
      register_sign ' '
      walkable false
    end

    # [ ##] [ # ] [ ##] [ # ]
    # [## ] [## ] [## ] [## ]
    # [# #] [# #] [#  ] [#  ]
    #
    # [ ##] [ # ] [ ##] [ # ]
    # [## ] [## ] [## ] [## ]
    # [  #] [  #] [   ] [   ]
    class Chipped168 < Wall
      register_type :chipped_168
      register_sign ' '
      walkable false
    end

    # [ ##]
    # [###]
    # [ # ]
    class Chipped179 < Wall
      register_type :chipped_179
      register_sign ' '
      walkable false
    end

    # [# #] [  #] [#  ] [   ]
    # [ # ] [ # ] [ # ] [ # ]
    # [###] [###] [###] [###]
    #
    # [# #] [  #] [#  ] [   ]
    # [ # ] [ # ] [ # ] [ # ]
    # [ ##] [ ##] [ ##] [ ##]
    #
    # [# #] [  #] [#  ] [   ]
    # [ # ] [ # ] [ # ] [ # ]
    # [## ] [## ] [## ] [## ]
    #
    # [# #] [  #] [#  ] [   ]
    # [ # ] [ # ] [ # ] [ # ]
    # [ # ] [ # ] [ # ] [ # ]
    class Chipped246 < Wall
      register_type :chipped_246
      register_sign ' '
      walkable false
    end

    # [# #] [  #] [#  ] [   ]
    # [ ##] [ ##] [ ##] [ ##]
    # [# #] [# #] [# #] [# #]
    #
    # [# #] [  #] [#  ] [   ]
    # [ ##] [ ##] [ ##] [ ##]
    # [  #] [  #] [  #] [  #]
    #
    # [# #] [  #] [#  ] [   ]
    # [ ##] [ ##] [ ##] [ ##]
    # [#  ] [#  ] [#  ] [#  ]
    #
    # [# #] [  #] [#  ] [   ]
    # [ ##] [ ##] [ ##] [ ##]
    # [   ] [   ] [   ] [   ]
    class Chipped248 < Wall
      register_type :chipped_248
      register_sign ' '
      walkable false
    end

    # [# #] [  #] [#  ] [   ]
    # [ ##] [ ##] [ ##] [ ##]
    # [## ] [## ] [## ] [## ]
    #
    # [# #] [  #] [#  ] [   ]
    # [ ##] [ ##] [ ##] [ ##]
    # [ # ] [ # ] [ # ] [ # ]
    class Chipped249 < Wall
      register_type :chipped_249
      register_sign ' '
      walkable false
    end

    # [# #] [  #] [#  ] [   ]
    # [## ] [## ] [## ] [## ]
    # [ ##] [ ##] [ ##] [ ##]
    #
    # [# #] [  #] [#  ] [   ]
    # [## ] [## ] [## ] [## ]
    # [ # ] [ # ] [ # ] [ # ]
    class Chipped267 < Wall
      register_type :chipped_267
      register_sign ' '
      walkable false
    end

    # [# #] [  #] [#  ] [   ]
    # [## ] [## ] [## ] [## ]
    # [# #] [# #] [# #] [# #]
    #
    # [# #] [  #] [#  ] [   ]
    # [## ] [## ] [## ] [## ]
    # [  #] [  #] [  #] [  #]
    #
    # [# #] [  #] [#  ] [   ]
    # [## ] [## ] [## ] [## ]
    # [#  ] [#  ] [#  ] [#  ]
    #
    # [# #] [  #] [#  ] [   ]
    # [## ] [## ] [## ] [## ]
    # [   ] [   ] [   ] [   ]
    class Chipped268 < Wall
      register_type :chipped_268
      register_sign ' '
      walkable false
    end

    # [# #] [  #] [#  ] [   ]
    # [###] [###] [###] [###]
    # [ # ] [ # ] [ # ] [ # ]
    class Chipped279 < Wall
      register_type :chipped_279
      register_sign ' '
      walkable false
    end

    # [## ] [ # ] [## ] [ # ]
    # [ ##] [ ##] [ ##] [ ##]
    # [# #] [# #] [  #] [  #]
    #
    # [## ] [ # ] [## ] [ # ]
    # [ ##] [ ##] [ ##] [ ##]
    # [#  ] [#  ] [   ] [   ]
    class Chipped348 < Wall
      register_type :chipped_348
      register_sign ' '
      walkable false
    end

    # [## ] [ # ] [## ] [ # ]
    # [ ##] [ ##] [ ##] [ ##]
    # [## ] [## ] [ # ] [ # ]
    class Chipped349 < Wall
      register_type :chipped_349
      register_sign ' '
      walkable false
    end

    # [## ]
    # [###]
    # [ # ]
    class Chipped379 < Wall
      register_type :chipped_379
      register_sign ' '
      walkable false
    end

    # [###] [ ##] [###] [ ##]
    # [ # ] [ # ] [ # ] [ # ]
    # [# #] [# #] [  #] [  #]
    #
    # [## ] [ # ] [## ] [ # ]
    # [ # ] [ # ] [ # ] [ # ]
    # [# #] [# #] [  #] [  #]
    #
    # [###] [ ##] [###] [ ##]
    # [ # ] [ # ] [ # ] [ # ]
    # [#  ] [#  ] [   ] [   ]
    #
    # [## ] [ # ] [## ] [ # ]
    # [ # ] [ # ] [ # ] [ # ]
    # [#  ] [#  ] [   ] [   ]
    class Chipped468 < Wall
      register_type :chipped_468
      register_sign ' '
      walkable false
    end

    # [ # ]
    # [###]
    # [ # ]
    class Chipped1379 < Wall
      register_type :chipped_1379
      register_sign ' '
      walkable false
    end

    # [# #] [  #] [#  ] [   ]
    # [ # ] [ # ] [ # ] [ # ]
    # [# #] [# #] [# #] [# #]
    #
    # [# #] [  #] [#  ] [   ]
    # [ # ] [ # ] [ # ] [ # ]
    # [  #] [  #] [  #] [  #]
    #
    # [# #] [  #] [#  ] [   ]
    # [ # ] [ # ] [ # ] [ # ]
    # [#  ] [#  ] [#  ] [#  ]
    #
    # [# #] [  #] [#  ] [   ]
    # [ # ] [ # ] [ # ] [ # ]
    # [   ] [   ] [   ] [   ]
    class Chipped2468 < Wall
      register_type :chipped_2468
      register_sign ' '
      walkable false
    end

    ###### ここまでdetailed Tile #####################################

    DEFAULT_TILE_CLASS = {
      wall: Wall,
      flat: Flat,
      gate: Gate,
      passage: Passage,
      binary_wall: BinaryWall,

      # for rogue_like
      l_wall: LWall,
      r_wall: RWall,
      t_wall: TWall,
      b_wall: BWall,

      # for detail
      chipped_1:    Chipped1,
      chipped_2:    Chipped2,
      chipped_3:    Chipped3,
      chipped_4:    Chipped4,
      chipped_6:    Chipped6,
      chipped_7:    Chipped7,
      chipped_8:    Chipped8,
      chipped_9:    Chipped9,
      chipped_13:   Chipped13,
      chipped_16:   Chipped16,
      chipped_17:   Chipped17,
      chipped_18:   Chipped18,
      chipped_19:   Chipped19,
      chipped_24:   Chipped24,
      chipped_26:   Chipped26,
      chipped_27:   Chipped27,
      chipped_28:   Chipped28,
      chipped_29:   Chipped29,
      chipped_34:   Chipped34,
      chipped_37:   Chipped37,
      chipped_38:   Chipped38,
      chipped_39:   Chipped39,
      chipped_46:   Chipped46,
      chipped_48:   Chipped48,
      chipped_49:   Chipped49,
      chipped_67:   Chipped67,
      chipped_68:   Chipped68,
      chipped_79:   Chipped79,
      chipped_137:  Chipped137,
      chipped_138:  Chipped138,
      chipped_139:  Chipped139,
      chipped_167:  Chipped167,
      chipped_168:  Chipped168,
      chipped_179:  Chipped179,
      chipped_246:  Chipped246,
      chipped_248:  Chipped248,
      chipped_249:  Chipped249,
      chipped_267:  Chipped267,
      chipped_268:  Chipped268,
      chipped_279:  Chipped279,
      chipped_348:  Chipped348,
      chipped_349:  Chipped349,
      chipped_379:  Chipped379,
      chipped_468:  Chipped468,
      chipped_1379: Chipped1379,
      chipped_2468: Chipped2468,
    }

    TileManager.set_tile_class(DEFAULT_TILE_CLASS)
  end
end
