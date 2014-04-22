module Meiro
  class RogueLikeTileManager < TileManager
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
          s = (tile.instance_of?(flat)) ? '1' : '0'
          pattern << s
        end
        pattern.to_i(2)
      end

      # 3x3のタイルパターンから、中心のタイルが何に分類されるかを
      # 示すマップを返す。1は床を、0は床以外を意味する。よって、
      #
      # 0b000_000_000 は
      #
      # 000
      # 000
      # 000
      #
      # を、すなわち9マス全て床以外となっている状態を意味する。
      def pattern_tile_map
        @pattern_tile_map ||
          @pattern_tile_map = {
          0b000_000_000 => wall,
          0b000_000_001 => l_wall,
          0b000_000_011 => t_wall,
          0b000_000_100 => r_wall,
          0b000_000_110 => t_wall,
          0b000_000_111 => t_wall,
          0b000_001_001 => l_wall,
          0b000_100_100 => r_wall,
          0b001_000_000 => l_wall,
          0b001_001_000 => l_wall,
          0b001_001_001 => l_wall,
          0b011_000_000 => b_wall,
          0b100_000_000 => r_wall,
          0b100_100_000 => r_wall,
          0b100_100_100 => r_wall,
          0b110_000_000 => b_wall,
          0b111_000_000 => b_wall,
        }
      end
    end
  end
end
