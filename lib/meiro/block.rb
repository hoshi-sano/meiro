module Meiro
  class Block
    MIN_WIDTH = FLOOR_MIN_WIDTH * 2 + 1
    MIN_HEIGHT = FLOOR_MIN_HEIGHT * 2 + 1
    MARGIN = 1

    attr_reader :x, :y, :width, :height,
                :upper_left, :lower_right,
                 :partition, :room

    def initialize(x, y, width, height, parent=nil)
      @x = x
      @y = y
      @width = width
      @height = height
      @parent = parent
      if @width >= @height
        @shape = :horizontal
      else
        @shape = :vertical
      end
      @separated = false
    end

    def separate
      return false if !separatable?
      if horizontal?
        vertical_separate
      else
        horizontal_separate
      end
      @separated = true
    end

    def unify
      @upper_left  = nil
      @lower_right = nil
      @partition = nil
      @separated = false
    end

    def separatable?
      # 分割済みのBlockはそれ以上分割できない
      return false if @separated

      if horizontal?
        (@width / 2) >= MIN_WIDTH
      else
        (@height / 2) >= MIN_HEIGHT
      end
    end

    def separated?
      @separated
    end

    def horizontal?
      @shape == :horizontal ? true : false
    end

    def vertical?
      @shape == :vertical ? true : false
    end

    def generation
      @parent ? @parent.generation + 1 : 1
    end

    def flatten
      res = []
      if separated?
        res << [@upper_left.flatten, @lower_right.flatten]
      else
        res << self
      end
      res.flatten
    end

    # Block内にRoom(部屋)を配置する。
    # 引数にroomを渡した場合、そのroomが配置される。
    # 引数にroomを渡さない場合、ランダムに生成された部屋が配置される。
    def put_room(randomizer=nil, room=nil)
      if room
        return false if !suitable?(room)
        @room = room
      else
        randomizer ||= Random.new(Time.now.to_i)
        rand_w = randomizer.rand(ROOM_MIN_WIDTH..(@width - MARGIN * 2))
        rand_h = randomizer.rand(ROOM_MIN_HEIGHT..(@height - MARGIN * 2))
        @room = Room.new(rand_w, rand_h)
      end
      @room.block = self
      @room.set_random_coordinate(randomizer)
      true
    end

    def has_room?
      !!@room
    end

    def suitable?(room)
      @width - room.width >= MARGIN * 2 &&
        @height - room.height >= MARGIN * 2
    end

    private

    def horizontal_separate
      c = @height.even? ? 0 : 1
      block_height = (@height - c) / 2
      @upper_left  = self.class.new(@x, @y,
                                    @width, block_height, self)
      @lower_right = self.class.new(@x, @y + 1 + block_height,
                                    @width, @height - (1 + block_height), self)
      @partition = Partition.new(@x, @y + block_height, @width)
      self
    end

    def vertical_separate
      c = @width.even? ? 0 : 1
      block_width = (@width - c) / 2
      @upper_left  = self.class.new(@x, @y,
                                    block_width, @height, self)
      @lower_right = self.class.new(@x + 1 + block_width, @y,
                                    @width - (1 + block_width), @height, self)
      @partition = Partition.new(@x + block_width, @y, @height)
      self
    end
  end
end
