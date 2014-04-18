module Meiro
  class Room
    attr_reader :relative_x, :relative_y,
                :width, :height, :block

    def initialize(width, height)
      if width < ROOM_MIN_WIDTH || height < ROOM_MIN_HEIGHT
        raise "width/height is too small for Meiro::Room"
      end
      @width = width
      @height = height
    end

    def x
      return nil if @block.nil?
      @block.x + @relative_x
    end

    def y
      return nil if @block.nil?
      @block.y + @relative_y
    end

    def relative_x=(x)
      if @block
        if x < available_x_min || x > available_x_max
          raise "could not set relative_x-coordinate [#{x}] in this block.\n" \
                "you can use #{available_x_min}..#{available_x_max}"
        end
      end
      @relative_x = x
    end

    def relative_y=(y)
      if @block
        if y < available_y_min || y > available_y_max
          raise "could not set relative_y-coordinate [#{y}] in this block.\n" \
                "you can use #{available_y_min}..#{available_y_max}"
        end
      end
      @relative_y = y
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

    def set_random_coordinate(seed=nil)
      if @block.nil?
        raise "Block is not found"
      else
        r = Random.new(seed || Time.now.to_i)
        self.relative_x = r.rand(available_x_min..available_x_max)
        self.relative_y = r.rand(available_y_min..available_y_max)
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
  end
end
