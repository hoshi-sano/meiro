module Meiro
  FLOOR_MIN_WIDTH = 5
  FLOOR_MIN_HEIGHT = FLOOR_MIN_WIDTH
  ROOM_MIN_WIDTH = 3
  ROOM_MIN_HEIGHT = ROOM_MIN_WIDTH

  class Dungeon
    class Config < Options
      option :width,  Integer, 60, lambda {|w,o| w >= FLOOR_MIN_WIDTH }
      option :height, Integer, 40, lambda {|h,o| h >= FLOOR_MIN_HEIGHT }
      option :min_room_number, Integer, 1, lambda {|n,o| n > 0 }
      option :max_room_number, Integer, 6, lambda {|n,o| n >= o[:min_room_number] }
      option :min_room_width,  Integer, 8, lambda {|w,o| w >= ROOM_MIN_WIDTH }
      option :min_room_height, Integer, 6, lambda {|h,o| h >= ROOM_MIN_HEIGHT }
      option :max_room_width,  Integer, 20, lambda {|w,o| w >= o[:min_room_width] }
      option :max_room_height, Integer, 20, lambda {|h,o| h >= o[:min_room_height] }
      option :block_split_factor, Float, 1.0, lambda {|n,o| n > 0 }
    end

    module FloorInitializer
      def initialize
      end
    end

    attr_accessor :width, :height,
                  :min_room_number, :max_room_number,
                  :min_room_width,  :min_room_height,
                  :max_room_width,  :max_room_height,
                  :block_split_factor

    def initialize(options={})
      config = Config.new(options)
      @width = config.width
      @height = config.height
      @min_room_number = config.min_room_number
      @max_room_number = config.max_room_number
      @min_room_width  = config.min_room_width
      @min_room_height = config.min_room_height
      @max_room_width  = config.max_room_width
      @max_room_height = config.max_room_height
      @block_split_factor = config.block_split_factor
      @randomizer = Random.new(Time.now.to_i)
    end

    def create_floor(mixin_floor_module=nil, mixin_room_module=nil)
      args = [self, @width, @height,
              @min_room_width, @min_room_height,
              @max_room_width, @max_room_height]
      f = Floor.new(*args)
      f.extend(FloorInitializer)
      f.extend(mixin_floor_module) if mixin_floor_module
      Block.set_mixin_room_module(mixin_room_module) if mixin_room_module
      f.instance_eval { initialize }
      f
    end

    def generate_random_floor(mixin_floor_module=nil, mixin_room_module=nil)
      floor = create_floor(mixin_floor_module, mixin_room_module)
      args = [@min_room_number, @max_room_number,
              @block_split_factor, @randomizer]
      floor.generate_random_room(*args)
    end
  end
end
