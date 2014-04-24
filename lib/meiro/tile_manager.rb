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
    end
  end
end
