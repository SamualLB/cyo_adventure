class CYOAdventure
  class Text < Content
    @text : String = ""

    def initialize(@node : Node, @text)
    end

    # Very basic version
    #
    # TODO: Add proper spacing around words for `#draw`
    def height : Int32
      (@text.size.to_f / W3MImageDisplay.width.to_f).ceil.to_i32
    end

    def draw(offset : Int32 = 0, height = 0)
      NCurses.print @text, offset, 0
    end

    def new_line
      true
    end
  end
end
