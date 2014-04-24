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

      [
       :wall,
       :flat,
       :gate,
       :passage,
       :binary_wall,

       # [## ] [###] [###] [## ] [## ]
       # [## ] [## ] [###] [## ] [###]
       # [## ] [## ] [## ] [###] [###]
       :l_wall,

       # [ ##] [###] [###] [ ##] [ ##]
       # [ ##] [ ##] [###] [ ##] [###]
       # [ ##] [ ##] [ ##] [###] [###]
       :r_wall,

       # [###] [###] [###]
       # [###] [###] [###]
       # [   ] [  #] [#  ]
       :t_wall,

       # [   ] [#  ] [  #]
       # [###] [###] [###]
       # [###] [###] [###]
       :b_wall,
      ].each do |name|
        define_method(name) { class_map[name] }
      end

      # def classify(tiles)
      # end
    end
  end
end
