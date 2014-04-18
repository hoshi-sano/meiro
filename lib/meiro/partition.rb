module Meiro
  class Partition
    attr_reader :x, :y, :length

    def initialize(x, y, length)
      @x = x
      @y = y
      @length = length
    end
  end
end
