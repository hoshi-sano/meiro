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
          m.clear_class_map
        end
      end

      def class_map
        @class_map || TileManager.instance_variable_get(:@class_map)
      end

      def clear_class_map
        @class_map = nil
      end

      [
       :wall,
       :flat,
       :gate,
       :passage,
       :binary_wall,

       # for rogue_like
       :l_wall,
       :r_wall,
       :t_wall,
       :b_wall,

       # for detail
       :chipped_1,
       :chipped_2,
       :chipped_3,
       :chipped_4,
       :chipped_6,
       :chipped_7,
       :chipped_8,
       :chipped_9,
       :chipped_13,
       :chipped_16,
       :chipped_17,
       :chipped_18,
       :chipped_19,
       :chipped_24,
       :chipped_26,
       :chipped_27,
       :chipped_28,
       :chipped_29,
       :chipped_34,
       :chipped_37,
       :chipped_38,
       :chipped_39,
       :chipped_46,
       :chipped_48,
       :chipped_49,
       :chipped_67,
       :chipped_68,
       :chipped_79,
       :chipped_137,
       :chipped_138,
       :chipped_139,
       :chipped_167,
       :chipped_168,
       :chipped_179,
       :chipped_246,
       :chipped_248,
       :chipped_249,
       :chipped_267,
       :chipped_268,
       :chipped_279,
       :chipped_348,
       :chipped_349,
       :chipped_379,
       :chipped_468,
       :chipped_1379,
       :chipped_2468,
      ].each do |name|
        define_method(name) { class_map[name] }
      end

      # def classify(tiles)
      # end
    end
  end
end
