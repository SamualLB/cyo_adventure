require "./content"

class CYOAdventure
  class Choice < Content

    @destination : Int32
    @text : String
    @selected = false

    def initialize(@node : Node, hash_line : String)
      arr = hash_line.split(' ', 2)
      @destination = arr[0].split('c', 2)[1].to_i32
      @text = hash_line.split(' ', 2)[1]? || ""
    end

    def height : Int32
      1
    end

    def draw(offset = 0, height = 0)
      NCurses.print "C:#{@text} (#{@destination})", offset, 0
    end
  end
end