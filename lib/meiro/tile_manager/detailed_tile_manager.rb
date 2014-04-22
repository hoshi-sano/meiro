module Meiro
  class DetailedTileManager < TileManager
    class << self
      def classify(tiles)
        # TODO
        BinaryTileManager.classify(tiles)
      end
    end
  end
end
