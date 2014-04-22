module Meiro
  class BinaryTileManager < TileManager
    class << self
      def classify(tiles)
        target = tiles[1, 1]
        klass = target.walkable? ? flat : binary_wall
        if target.instance_of?(klass)
          target
        else
          klass.new
        end
      end
    end
  end
end
