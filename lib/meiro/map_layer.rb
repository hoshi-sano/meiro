module Meiro
  class MapLayer
    def initialize(width, height)
      @map = Array.new(height)
      @map.map! {|line| Array.new(width) }
    end

    def [](x, y)
      if 0 <= x && 0 <= y && x < width && y < height
        @map[y][x]
      else
        nil
      end
    end

    def []=(x, y, obj)
      @map[y][x] = obj
    end

    def width
      @map.first.size
    end

    def height
      @map.size
    end

    def each_line(&block)
      @map.each do |line|
        yield(line)
      end
    end

    def each_tile(&block)
      @map.each_with_index do |line, y|
        line.each_with_index do |tile, x|
          yield(x, y, tile)
        end
      end
    end

    def get_around(x, y)
      new = MapLayer.new(width, height)
      around = [
       [self[x-1, y-1], self[  x, y-1], self[x+1, y-1]],
       [self[x-1,   y], self[  x,   y], self[x+1,   y]],
       [self[x-1, y+1], self[  x, y+1], self[x+1, y+1]],
      ]
      new.instance_variable_set(:@map, around)
      new
    end

    def dup
      new = self.class.new(width, height)
      new.each_tile do |x, y, tile|
        new[x, y] = self[x, y].dup
      end
    end
  end

  class BaseMap < MapLayer
    def initialize(width, height, klass=nil)
      proc = klass.nil? ? lambda { nil } : lambda { klass.new }
      @map = Array.new(height)
      @map.map! {|line| Array.new(width).map! {|e| proc.call } }
    end

    def fill_rect(x1, y1, x2, y2, klass)
      x_begin, x_end = x1 <= x2 ? [x1, x2] : [x2, x1]
      y_begin, y_end = y1 <= y2 ? [y1, y2] : [y2, y1]

      (y_begin..y_end).each do |y|
        (x_begin..x_end).each do |x|
          self[x, y] = klass.new
        end
      end
    end

    def apply_room(room, klass)
      room.each_coordinate do |x, y|
        self[x, y] = klass.new
      end
    end

    def apply_passage(rooms, gate_klass, pass_klass)
      all_pass = []
      all_gates = []
      rooms.each do |room|
        all_pass << room.all_pass
        all_gates << room.gate_coordinates
      end

      all_pass.flatten.uniq.each do |p|
        self.fill_rect(p.start_x, p.start_y, p.end_x, p.end_y, pass_klass)
      end

      all_gates.flatten(1).each do |x, y|
        self[x, y] = gate_klass.new
      end
    end

    def classify(type=:rogue_like)
      res = self.class.new(width, height)
      res.each_tile do |x, y, tile|
        res[x, y] = Tile.classify(self.get_around(x, y), type)
      end
      res
    end

    def classify!(type=:rogue_like)
      self.each_tile do |x, y, tile|
        self[x, y] = Tile.classify(self.get_around(x, y), type)
      end
      self
    end
  end
end
