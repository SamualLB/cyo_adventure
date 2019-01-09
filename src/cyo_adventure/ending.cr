class CYOAdventure
  class Ending < Content

    def initialize(@node : Node)
    end

    def height : Int32
      1
    end

    def draw(offset = 0, height = 0)
      NCurses.print "test", offset, 0
    end
  end
end