module Meiro
  class Partition
    attr_reader :x, :y, :length

    def initialize(x, y, length, shape)
      @x = x
      @y = y
      @length = length
      @shape = shape
    end

    def horizontal?
      @shape == :horizontal
    end

    def vertical?
      @shape == :vertical
    end
  end
end
