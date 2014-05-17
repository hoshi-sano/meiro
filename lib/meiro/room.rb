module Meiro
  class Room
    attr_reader :relative_x, :relative_y,
                :width, :height, :block
    attr_accessor :connected_rooms, :all_pass

    def initialize(width, height)
      if width < ROOM_MIN_WIDTH || height < ROOM_MIN_HEIGHT
        raise "width/height is too small for Meiro::Room"
      end
      @width = width
      @height = height
      @connected_rooms = {}
      @all_pass = []
    end

    # floorにおける絶対x座標
    # ブロックのx座標に、ブロックのx座標を基準とした相対x座標を足しあわ
    # せたものを返す
    def x
      return nil if @block.nil?
      @block.x + @relative_x
    end

    # floorにおける絶対y座標
    # ブロックのy座標に、ブロックのy座標を基準とした相対y座標を足しあわ
    # せたものを返す
    def y
      return nil if @block.nil?
      @block.y + @relative_y
    end

    # ブロックのx座標を基準とした相対x座標
    def relative_x=(x)
      if @block
        if x < available_x_min || x > available_x_max
          raise "could not set relative_x-coordinate [#{x}] in this block.\n" \
                "you can use #{available_x_min}..#{available_x_max}"
        end
      end
      @relative_x = x
    end

    # ブロックのy座標を基準とした相対y座標
    def relative_y=(y)
      if @block
        if y < available_y_min || y > available_y_max
          raise "could not set relative_y-coordinate [#{y}] in this block.\n" \
                "you can use #{available_y_min}..#{available_y_max}"
        end
      end
      @relative_y = y
    end

    # 部屋のマスの全ての絶対xy座標を返す
    def get_all_abs_coordinate
      res = []
      self.each_coordinate do |_x, _y|
        res << [_x, _y]
      end
      res
    end

    # 引数で渡した座標を部屋の内部に含むかどうかを返す
    def include?(_x, _y)
      self.get_all_abs_coordinate.include?([_x, _y])
    end

    def block=(block)
      @block = block
      if @relative_x && @relative_y
        begin
          # 再代入して x, y が適切かチェック
          self.relative_x = @relative_x
          self.relative_y = @relative_y
        rescue => e
          @block = nil
          raise e
        end
      end
      @block
    end

    def set_random_coordinate(randomizer=nil)
      if @block.nil?
        raise "Block is not found"
      else
        randomizer ||= Random.new(Time.now.to_i)
        self.relative_x = randomizer.rand(available_x_min..available_x_max)
        self.relative_y = randomizer.rand(available_y_min..available_y_max)
      end
      return [@relative_x, @relative_y]
    end

    def available_x_min
      Block::MARGIN
    end

    def available_x_max
      @block.width - (@width + Block::MARGIN)
    end

    def available_y_min
      Block::MARGIN
    end

    def available_y_max
      @block.height - (@height + Block::MARGIN)
    end

    def each_coordinate(&block)
      @height.times do |h|
        @width.times do |w|
          yield(x + w, y + h)
        end
      end
    end

    def generation
      @block.generation if @block
    end

    def partition
      @block.partition if @block
    end

    def brother
      @block.brother.room if @block && @block.brother
    end

    def gate_coordinates
      @connected_rooms.keys
    end

    def all_connected_rooms
      @connected_rooms.values
    end

    def create_passage(randomizer=nil)
      randomizer ||= Random.new(Time.now.to_i)
      connectable_rooms.each do |room|
        create_passage_to(room, randomizer)
      end
    end

    # この部屋と通路で接続可能な部屋を返す
    def connectable_rooms
      rooms = []
      # 隣接するブロックに所属する部屋を接続可能とする
      @block.neighbors.each do |b|
        rooms << b.room if b.has_room?
      end
      rooms
    end

    # 接続対象の部屋との仕切り(Partition)を返す
    def select_partition(room)
      @block.find_ancestor(room.block).partition
    end

    # 部屋からPartitionに向けて伸ばす通路の出口を決める
    def get_random_gate(partition, randomizer=nil)
      randomizer ||= Random.new(Time.now.to_i)
      if partition.horizontal?
        if self.y < partition.y
          # Partitionがこの部屋より下にある
          gate_y = self.y + @height
        else
          # Partitionがこの部屋より上にある
          gate_y = self.y - 1
        end
        gate_x = randomizer.rand((self.x + 1)...(self.x + @width - 1))
        checker = [[0, 0], [1, 0], [-1, 0]]
      else
        if self.x < partition.x
          # Partitionがこの部屋より右にある
          gate_x = self.x + @width
        else
          # Partitionがこの部屋より左にある
          gate_x = self.x - 1
        end
        gate_y = randomizer.rand((self.y + 1)...(self.y + @height - 1))
        checker = [[0, 0], [0, 1], [0, -1]]
      end

      retry_flg = false
      checker.each do |dx, dy|
        # 同一の、またはとなり合うGateが作られた場合はやり直し
        retry_flg |= true if @connected_rooms[[gate_x + dx, gate_y + dy]]
      end
      gate_x, gate_y = get_random_gate(partition, randomizer) if retry_flg

      [gate_x, gate_y]
    end

    # 自身と引数で渡した部屋とを接続する通路を作成する
    def create_passage_to(room, randomizer=nil)
      # 接続済みの部屋とは何もしない
      return true if all_connected_rooms.include?(room)
      # 同じ親の同世代の部屋と接続済みなら何もしない
      return true if brother && brother.all_connected_rooms.include?(room)

      randomizer ||= Random.new(Time.now.to_i)
      partition = select_partition(room)

      # 部屋から通路への出口を決定
      gate_xy = self.get_random_gate(partition, randomizer)
      o_gate_xy = room.get_random_gate(partition, randomizer)

      created_pass = []
      # 各部屋のGateからPartitionへ伸びる通路を作成
      [gate_xy, o_gate_xy].each do |gx, gy|
        if partition.horizontal?
          created_pass << Passage.new(gx, gy, gx, partition.y)
        else
          created_pass << Passage.new(gx, gy, partition.x, gy)
        end
      end

      # 上で作られた通路同士を連結する通路を作成
      created_pass << Passage.new(created_pass[0].end_x, created_pass[0].end_y,
                                  created_pass[1].end_x, created_pass[1].end_y)

      created_pass.each do |p|
        @all_pass << p
        room.all_pass << p
      end
      @connected_rooms[gate_xy] = room
      room.connected_rooms[o_gate_xy] = self
      true
    end
  end
end
