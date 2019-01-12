class CYOAdventure
  class Ending < Content

    def initialize(@node : Node)
    end

    def height : Int32
      0
    end

    def draw(offset = 0, height = 0)
    end

    def new_line
      false
    end
  end
end