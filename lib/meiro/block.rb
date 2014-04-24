module Meiro
  class Block
    MIN_WIDTH = FLOOR_MIN_WIDTH * 2 + 1
    MIN_HEIGHT = FLOOR_MIN_HEIGHT * 2 + 1
    MARGIN = 1

    attr_reader :x, :y, :width, :height,
                :upper_left, :lower_right,
                :partition, :room, :parent

    def initialize(floor, x, y, width, height, parent=nil)
      @floor = floor
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

    # 共通の親(先祖)を返す
    def find_ancestor(other)
      return nil if !self.parent || !other.parent

      # 世代を揃える
      if self.generation >= other.generation
        younger, older = self, other
      else
        younger, older = other, self
      end
      diff = younger.generation - older.generation
      diff.times { younger = younger.parent }

      # 親が同一になるまで遡る
      until younger.parent == older.parent
        younger = younger.parent
        older = older.parent
      end

      younger.parent
    end

    # 同じ親から分割された片割れを返す。
    # 親がいない場合はnilを返す。
    def brother
      if @parent
        bros = [@parent.upper_left, @parent.lower_right]
        bros.delete(self)
        bros.pop
      else
        nil
      end
    end

    # 辺を共有するBlockを返す。そのBlockが親(分割済)であった場合は、分
    # 割されたいずれかのうち、辺を共有している方を返す。
    def neighbors
      got = []
      neighborhood_xy.each do |x, y|
        got << @floor.get_block(x, y)
      end
      got.compact.uniq
    end

    # 指定した座標が自身に含まれるか否かを返す
    def include?(x, y)
      @x <= x && x <= (@x + @width) &&
        @y <= y && y <= (@y + @height)
    end

    # 辺を共有するBlockを検索するため、辺を共有するBlockがある場合には
    # それに含まれるであろうx座標、y座標を返す
    def neighborhood_xy
      res = []
      c = 2 # Partitionがあるため、端から2マス先を見る必要がある
      if @x - c >= 0
        res << (@y..(@y + @height)).map {|y| [@x - c, y] }
      end
      if @x + @width + c <= @floor.width
        res << (@y..(@y + @height)).map {|y| [@x + @width + c, y] }
      end
      if @y - c >= 0
        res << (@x..(@x + @width)).map {|x| [x, @y - c] }
      end
      if @y + @height + c <= @floor.height
        res << (@x..(@x + @width)).map {|x| [x, @y + @height + c] }
      end
      res.flatten(1)
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
    def put_room(randomizer_or_room=nil)
      randomizer_or_room ||= Random.new(Time.now.to_i)
      case randomizer_or_room
      when Room
        room = randomizer_or_room
        return false if !suitable?(room)
        @room = room
      when Random
        randomizer = randomizer_or_room
        min_w = @floor.min_room_width
        min_h = @floor.min_room_height
        max_w = [@floor.max_room_width, (@width - MARGIN * 2)].min
        max_h = [@floor.max_room_height, (@height - MARGIN * 2)].min
        rand_w = randomizer.rand(min_w..max_w)
        rand_h = randomizer.rand(min_h..max_h)
        @room = Room.new(rand_w, rand_h)
      else
        return false
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

    # 横分割 (上下に新しいBlockが生成される)
    def horizontal_separate
      c = @height.even? ? 0 : 1
      block_height = (@height - c) / 2
      @upper_left  = self.class.new(@floor, @x, @y,
                                    @width, block_height, self)
      @lower_right = self.class.new(@floor, @x, @y + 1 + block_height,
                                    @width, @height - (1 + block_height), self)
      @partition = Partition.new(@x, @y + block_height, @width, :horizontal)
      self
    end

    # 縦分割 (左右に新しいBlockが生成される)
    def vertical_separate
      c = @width.even? ? 0 : 1
      block_width = (@width - c) / 2
      @upper_left  = self.class.new(@floor, @x, @y,
                                    block_width, @height, self)
      @lower_right = self.class.new(@floor, @x + 1 + block_width, @y,
                                    @width - (1 + block_width), @height, self)
      @partition = Partition.new(@x + block_width, @y, @height, :vertical)
      self
    end
  end
end
