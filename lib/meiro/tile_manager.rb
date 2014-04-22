module Meiro
  class TileManager
    class << self
      def set_tile_class(class_map)
        @class_map ||= {}
        @class_map.merge!(class_map)

        [
         RogueLikeTileManager,
         DetailedTileManager,
        ].each do |m|
          m.instance_variable_set(:@pattern_tile_map, nil)
        end
      end

      def class_map
        @class_map || TileManager.instance_variable_get(:@class_map)
      end

      def wall
        class_map[:wall]
      end

      def flat
        class_map[:flat]
      end

      def gate
        class_map[:gate]
      end

      def passage
        class_map[:passage]
      end

      def binary_wall
        class_map[:bin_wall]
      end

      # [## ] [###] [###] [## ] [## ]
      # [## ] [## ] [###] [## ] [###]
      # [## ] [## ] [## ] [###] [###]
      def l_wall
        class_map[:l_wall]
      end

      # [ ##] [###] [###] [ ##] [ ##]
      # [ ##] [ ##] [###] [ ##] [###]
      # [ ##] [ ##] [ ##] [###] [###]
      def r_wall
        class_map[:r_wall]
      end

      # [###] [###] [###]
      # [###] [###] [###]
      # [   ] [  #] [#  ]
      def t_wall
        class_map[:t_wall]
      end

      # [   ] [#  ] [  #]
      # [###] [###] [###]
      # [###] [###] [###]
      def b_wall
        class_map[:b_wall]
      end

      # def classify(tiles)
      # end

      def rogue_like_classify(tiles)
        binary_classify(tiles)
      end

      def detailed_classify(tiles)
        binary_classify(tiles)
      end

      def binary_classify(tiles)
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
