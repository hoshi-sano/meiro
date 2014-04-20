module Meiro
  class Passage
    def initialize(x1, y1, x2, y2)
      @start = [x1, y1]
      @end = [x2, y2]
    end

    def start_x
      @start[0]
    end

    def start_y
      @start[1]
    end

    def end_x
      @end[0]
    end

    def end_y
      @end[1]
    end
  end
end
