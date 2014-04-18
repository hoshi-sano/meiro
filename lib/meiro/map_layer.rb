module Meiro
  class MapLayer
    def initialize(width, height)
      @map = Array.new(height)
      @map.map! {|line| Array.new(width) }
    end

    def [](x, y)
      @map[y][x]
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
  end

  class BaseMap < MapLayer
    def initialize(width, height, klass=nil)
      proc = klass.nil? ? lambda { nil } : lambda { klass.new }
      @map = Array.new(height)
      @map.map! {|line| Array.new(width).map! {|e| proc.call } }
    end

    def apply_room(room, klass)
      room.each_coordinate do |x, y|
        self[x, y] = klass.new
      end
    end
  end
end
