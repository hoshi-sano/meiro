module Meiro
  class DetailedTileManager < TileManager
    class << self
      def classify(tiles)
        target = tiles[1, 1]
        if target.walkable?
          target
        else
          pattern = get_3x3_tile_pattern(tiles)
          pattern_tile_map[pattern].new
        end
      end

      def get_3x3_tile_pattern(tiles)
        pattern = ""
        tiles.each_tile do |x, y, tile|
          if tile
            s = tile.walkable? ? '1' : '0'
          else
            s = '0'
          end
          pattern << s
        end
        pattern.to_i(2)
      end

      # 3x3のタイルパターンから、中心のタイルが何に分類されるかを
      # 示すマップを返す。1は歩行可能な床を、0は歩行不可能な床(壁)を意
      # 味する。よって、
      #
      # 0b000_000_000 は
      #
      # 000
      # 000
      # 000
      #
      # を、すなわち9マス全て歩行不可能となっている状態を意味する。
      def pattern_tile_map
        @pattern_tile_map ||
          @pattern_tile_map = {
          0b000_000_000 => wall,

          0b100_000_000 => chipped_1,

          0b010_000_000 => chipped_2,
          0b110_000_000 => chipped_2,
          0b011_000_000 => chipped_2,
          0b111_000_000 => chipped_2,

          0b001_000_000 => chipped_3,

          0b000_100_000 => chipped_4,
          0b100_100_000 => chipped_4,
          0b000_100_100 => chipped_4,
          0b100_100_100 => chipped_4,

          0b000_001_000 => chipped_6,
          0b001_001_000 => chipped_6,
          0b000_001_001 => chipped_6,
          0b001_001_001 => chipped_6,

          0b000_000_100 => chipped_7,

          0b000_000_010 => chipped_8,
          0b000_000_011 => chipped_8,
          0b000_000_110 => chipped_8,
          0b000_000_111 => chipped_8,

          0b000_000_001 => chipped_9,

          0b101_000_000 => chipped_13,

          0b100_001_000 => chipped_16,
          0b100_001_001 => chipped_16,
          0b101_001_000 => chipped_16,
          0b101_001_001 => chipped_16,

          0b100_000_100 => chipped_17,

          0b100_000_010 => chipped_18,
          0b100_000_011 => chipped_18,
          0b100_000_110 => chipped_18,
          0b100_000_111 => chipped_18,

          0b100_000_001 => chipped_19,

          0b010_100_000 => chipped_24,
          0b011_100_000 => chipped_24,
          0b110_100_000 => chipped_24,
          0b111_100_000 => chipped_24,
          0b010_100_100 => chipped_24,
          0b011_100_100 => chipped_24,
          0b110_100_100 => chipped_24,
          0b111_100_100 => chipped_24,

          0b010_001_000 => chipped_26,
          0b011_001_000 => chipped_26,
          0b110_001_000 => chipped_26,
          0b111_001_000 => chipped_26,
          0b010_001_001 => chipped_26,
          0b011_001_001 => chipped_26,
          0b110_001_001 => chipped_26,
          0b111_001_001 => chipped_26,

          0b010_000_100 => chipped_27,
          0b110_000_100 => chipped_27,
          0b011_000_100 => chipped_27,
          0b111_000_100 => chipped_27,

          0b010_000_010 => chipped_28,
          0b110_000_010 => chipped_28,
          0b011_000_010 => chipped_28,
          0b111_000_010 => chipped_28,
          0b010_000_011 => chipped_28,
          0b110_000_011 => chipped_28,
          0b011_000_011 => chipped_28,
          0b111_000_011 => chipped_28,
          0b010_000_110 => chipped_28,
          0b110_000_110 => chipped_28,
          0b011_000_110 => chipped_28,
          0b111_000_110 => chipped_28,
          0b010_000_111 => chipped_28,
          0b110_000_111 => chipped_28,
          0b011_000_111 => chipped_28,
          0b111_000_111 => chipped_28,

          0b010_000_001 => chipped_29,
          0b110_000_001 => chipped_29,
          0b011_000_001 => chipped_29,
          0b111_000_001 => chipped_29,

          0b001_100_000 => chipped_34,
          0b101_100_000 => chipped_34,
          0b001_100_100 => chipped_34,
          0b101_100_100 => chipped_34,

          0b001_000_100 => chipped_37,

          0b001_000_010 => chipped_38,
          0b001_000_110 => chipped_38,
          0b001_000_011 => chipped_38,
          0b001_000_111 => chipped_38,

          0b001_000_001 => chipped_39,

          0b000_101_000 => chipped_46,
          0b100_101_000 => chipped_46,
          0b000_101_100 => chipped_46,
          0b100_101_100 => chipped_46,
          0b001_101_000 => chipped_46,
          0b101_101_000 => chipped_46,
          0b001_101_100 => chipped_46,
          0b101_101_100 => chipped_46,
          0b000_101_001 => chipped_46,
          0b100_101_001 => chipped_46,
          0b000_101_101 => chipped_46,
          0b100_101_101 => chipped_46,
          0b001_101_001 => chipped_46,
          0b101_101_001 => chipped_46,
          0b001_101_101 => chipped_46,
          0b101_101_101 => chipped_46,

          0b000_100_010 => chipped_48,
          0b100_100_010 => chipped_48,
          0b000_100_110 => chipped_48,
          0b100_100_110 => chipped_48,
          0b000_100_011 => chipped_48,
          0b100_100_011 => chipped_48,
          0b000_100_111 => chipped_48,
          0b100_100_111 => chipped_48,

          0b000_100_001 => chipped_49,
          0b100_100_001 => chipped_49,
          0b000_100_101 => chipped_49,
          0b100_100_101 => chipped_49,

          0b000_001_100 => chipped_67,
          0b001_001_100 => chipped_67,
          0b000_001_101 => chipped_67,
          0b001_001_101 => chipped_67,

          0b000_001_010 => chipped_68,
          0b001_001_010 => chipped_68,
          0b000_001_011 => chipped_68,
          0b001_001_011 => chipped_68,
          0b000_001_110 => chipped_68,
          0b001_001_110 => chipped_68,
          0b000_001_111 => chipped_68,
          0b001_001_111 => chipped_68,

          0b000_000_101 => chipped_79,

          0b101_000_100 => chipped_137,

          0b101_000_010 => chipped_138,
          0b101_000_110 => chipped_138,
          0b101_000_011 => chipped_138,
          0b101_000_111 => chipped_138,

          0b101_000_001 => chipped_139,

          0b100_001_100 => chipped_167,
          0b101_001_100 => chipped_167,
          0b100_001_101 => chipped_167,
          0b101_001_101 => chipped_167,

          0b100_001_010 => chipped_168,
          0b101_001_010 => chipped_168,
          0b100_001_011 => chipped_168,
          0b101_001_011 => chipped_168,
          0b100_001_110 => chipped_168,
          0b101_001_110 => chipped_168,
          0b100_001_111 => chipped_168,
          0b101_001_111 => chipped_168,

          0b100_000_101 => chipped_179,

          0b010_101_000 => chipped_246,
          0b110_101_000 => chipped_246,
          0b011_101_000 => chipped_246,
          0b111_101_000 => chipped_246,
          0b010_101_100 => chipped_246,
          0b110_101_100 => chipped_246,
          0b011_101_100 => chipped_246,
          0b111_101_100 => chipped_246,
          0b010_101_001 => chipped_246,
          0b110_101_001 => chipped_246,
          0b011_101_001 => chipped_246,
          0b111_101_001 => chipped_246,
          0b010_101_101 => chipped_246,
          0b110_101_101 => chipped_246,
          0b011_101_101 => chipped_246,
          0b111_101_101 => chipped_246,

          0b010_100_010 => chipped_248,
          0b110_100_010 => chipped_248,
          0b011_100_010 => chipped_248,
          0b111_100_010 => chipped_248,
          0b010_100_110 => chipped_248,
          0b110_100_110 => chipped_248,
          0b011_100_110 => chipped_248,
          0b111_100_110 => chipped_248,
          0b010_100_011 => chipped_248,
          0b110_100_011 => chipped_248,
          0b011_100_011 => chipped_248,
          0b111_100_011 => chipped_248,
          0b010_100_111 => chipped_248,
          0b110_100_111 => chipped_248,
          0b011_100_111 => chipped_248,
          0b111_100_111 => chipped_248,

          0b010_100_001 => chipped_249,
          0b110_100_001 => chipped_249,
          0b011_100_001 => chipped_249,
          0b111_100_001 => chipped_249,
          0b010_100_101 => chipped_249,
          0b110_100_101 => chipped_249,
          0b011_100_101 => chipped_249,
          0b111_100_101 => chipped_249,

          0b010_001_100 => chipped_267,
          0b110_001_100 => chipped_267,
          0b011_001_100 => chipped_267,
          0b111_001_100 => chipped_267,
          0b010_001_101 => chipped_267,
          0b110_001_101 => chipped_267,
          0b011_001_101 => chipped_267,
          0b111_001_101 => chipped_267,

          0b010_001_010 => chipped_268,
          0b110_001_010 => chipped_268,
          0b011_001_010 => chipped_268,
          0b111_001_010 => chipped_268,
          0b010_001_110 => chipped_268,
          0b110_001_110 => chipped_268,
          0b011_001_110 => chipped_268,
          0b111_001_110 => chipped_268,
          0b010_001_011 => chipped_268,
          0b110_001_011 => chipped_268,
          0b011_001_011 => chipped_268,
          0b111_001_011 => chipped_268,
          0b010_001_111 => chipped_268,
          0b110_001_111 => chipped_268,
          0b011_001_111 => chipped_268,
          0b111_001_111 => chipped_268,

          0b010_000_101 => chipped_279,
          0b110_000_101 => chipped_279,
          0b011_000_101 => chipped_279,
          0b111_000_101 => chipped_279,

          0b001_100_010 => chipped_348,
          0b101_100_010 => chipped_348,
          0b001_100_110 => chipped_348,
          0b101_100_110 => chipped_348,
          0b001_100_011 => chipped_348,
          0b101_100_011 => chipped_348,
          0b001_100_111 => chipped_348,
          0b101_100_111 => chipped_348,

          0b001_100_001 => chipped_349,
          0b101_100_001 => chipped_349,
          0b001_100_101 => chipped_349,
          0b101_100_101 => chipped_349,

          0b001_000_101 => chipped_379,

          0b000_101_010 => chipped_468,
          0b100_101_010 => chipped_468,
          0b000_101_110 => chipped_468,
          0b100_101_110 => chipped_468,
          0b001_101_010 => chipped_468,
          0b101_101_010 => chipped_468,
          0b001_101_110 => chipped_468,
          0b101_101_110 => chipped_468,
          0b000_101_011 => chipped_468,
          0b100_101_011 => chipped_468,
          0b000_101_111 => chipped_468,
          0b100_101_111 => chipped_468,
          0b001_101_011 => chipped_468,
          0b101_101_011 => chipped_468,
          0b001_101_111 => chipped_468,
          0b101_101_111 => chipped_468,

          0b101_000_101 => chipped_1379,

          0b010_101_010 => chipped_2468,
          0b110_101_010 => chipped_2468,
          0b011_101_010 => chipped_2468,
          0b111_101_010 => chipped_2468,
          0b010_101_110 => chipped_2468,
          0b110_101_110 => chipped_2468,
          0b011_101_110 => chipped_2468,
          0b111_101_110 => chipped_2468,
          0b010_101_011 => chipped_2468,
          0b110_101_011 => chipped_2468,
          0b011_101_011 => chipped_2468,
          0b111_101_011 => chipped_2468,
          0b010_101_111 => chipped_2468,
          0b110_101_111 => chipped_2468,
          0b011_101_111 => chipped_2468,
          0b111_101_111 => chipped_2468,
        }
      end
    end
  end
end
