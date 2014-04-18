module Meiro
  class Floor
    TRY_SEPARATE_LIMIT = 1000000

    attr_reader :dungeon, :width, :height,
                :min_room_width, :min_room_height,
                :max_room_width, :max_room_height

    class Config < Options
      option :width,  Integer, nil, lambda {|w,o| !w.nil? && w >= FLOOR_MIN_WIDTH }
      option :height, Integer, nil, lambda {|h,o| !h.nil? && h >= FLOOR_MIN_HEIGHT }
      option :min_room_width,  Integer, nil, lambda {|w,o| !w.nil? && w >= ROOM_MIN_WIDTH }
      option :min_room_height, Integer, nil, lambda {|h,o| !h.nil? && h >= ROOM_MIN_HEIGHT }
      option :max_room_width,  Integer, nil, lambda {|w,o| !w.nil? && w >= o[:min_room_width] }
      option :max_room_height, Integer, nil, lambda {|h,o| !h.nil? && h >= o[:min_room_height] }
    end

    def initialize(d, w, h, min_rw, min_rh, max_rw, max_rh)
      opts = {
        width: w,
        height: h,
        min_room_width:  min_rw,
        min_room_height: min_rh,
        max_room_width:  max_rw,
        max_room_height: max_rh,
      }
      config = Config.new(opts)
      @dungeon = d
      @min_room_width  = config.min_room_width
      @min_room_height = config.min_room_height
      @max_room_width  = config.max_room_width
      @max_room_height = config.max_room_height
      @root_block = Block.new(self, 0, 0, config.width, config.height)
      fill_floor_by_wall(config.width, config.height)
    end

    def width
      @base_map.width
    end

    def height
      @base_map.height
    end

    def all_blocks
      @root_block.flatten
    end

    def all_rooms
      all_blocks.map{|b| b.room }
    end

    def to_s
      res = []
      @base_map.each_line do |line|
        res << (line.map(&:to_s) << "\n").join
      end
      res.join
    end

    def fill_floor_by_wall(w, h)
      @base_map = BaseMap.new(w, h, Tile::Wall)
    end

    # ランダムで部屋と通路を生成する
    def generate_random_room(r_min, r_max, factor, randomizer)
      separate_blocks(r_min, r_max, factor, randomizer)
      all_blocks.each do |block|
        block.put_room(randomizer)
      end
      # TODO: connect_rooms_by_aisle
      apply_rooms_to_map
      self
    end

    def apply_rooms_to_map
      all_rooms.each do |room|
        @base_map.apply_room(room, Tile::Flat)
      end
    end

    # 設定された部屋数のMIN,MAXの範囲に収まるよう区画をランダムで分割
    def separate_blocks(r_min, r_max, factor, randomizer)
      new_block = [@root_block]
      try_count = 0

      while new_block.any?
        tried = []
        separated = []
        next_new_block = []

        while b = new_block.shift
          if b.separatable? && do_separate?(b, factor, randomizer)
            b.separate
            separated << b
            next_new_block << b.upper_left
            next_new_block << b.lower_right
          end
          tried << b
        end

        block_num = @root_block.flatten.size
        if block_num > r_max
          # MAXを越えてしまったら直前の分割を取り消してやり直し
          separated.each {|b| b.unify }
          new_block = tried
        elsif next_new_block.empty? && block_num < r_min
          # 全ての分割が完了し、MINに到達しない場合は直前の分割をやり直し
          new_block = tried
        else
          new_block = next_new_block
        end

        try_count += 1
        raise "could not create expected floor" if try_count > TRY_SEPARATE_LIMIT
      end
      self
    end

    private

    def do_separate?(block, factor, randomizer)
      # Blockが細分化するほど、分割されづらくなる
      block.generation / factor < randomizer.rand(10)
    end
  end
end
