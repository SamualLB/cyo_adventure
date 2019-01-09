class CYOAdventure
  class Node
    include Interactable

    @content = [] of Content
    @current_content = 0

    @last_content_drawn : Int32 = 0

    def initialize(@book : CYOAdventure, text : String, dir : String)
      text.each_line do |line|
        if line.starts_with?('#')
          @content << Content.new(self, line, dir)
        else
          @content << Text.new(self, line)
        end
      end
    end

    def content : Content
      @content[@current_content]
    end

    def next_content : Content?
      @content[@current_content + 1]?
    end

    # Go forward in book
    def advance_content
      if @last_content_drawn == @content.size-1
        @book.change_node(@content[@content.size-1].as(Choice).@destination)
      else
        @current_content = @last_content_drawn+1
      end
    end

    # Go back in book
    def retreat_content
      if @current_content == 0
        # previous node
      else
        @current_content -= 1
      end
    end

    def handle_key(key) : Bool
      case key
      when NCurses::Key::Right then advance_content
      when NCurses::Key::Left then retreat_content
      else return false 
      end
      true
    end

    def handle_mouse(mouse) : Bool
      false
    end

    # Allow this to decide what to draw and store it for moving page...
    def draw
      current_index = @current_content
      current_content = @content[current_index]
      next_content : Content? = @content[current_index + 1]?
      previous_content : Content? = nil
      content_to_draw = [] of Content
      height = -1 # Account for gap at top
      loop do
        case current_content
        when Text
          if NCurses.height >= height + current_content.height + 1
            height += current_content.height + 1
            content_to_draw << current_content
          else
            break
          end
        when Image
          if NCurses.height >= height + current_content.height + 1
            height += current_content.height + 1
            content_to_draw << current_content
          else
            break
          end
        when Ending
          content_to_draw << current_content
          break
        when Choice
          case previous_content
          when Image # always add
            height += 2 # account for gap above
            content_to_draw << current_content
          when Choice # always add
            height += 1
            content_to_draw << current_content
          when Text # Add if there is enough space for all
            if NCurses.height >= height + 2
              height += 2
              content_to_draw << current_content
            else
              break
            end
          when Ending then raise "Choice should not come after ending"
          end
        end
        previous_content = current_content
        current_index += 1
        break unless @content[current_index]?
        current_content = @content[current_index]
        next_content = @content[current_index + 1]?
      end
      draw_content(content_to_draw)
    end

    private def draw_content(ctnt : Array(Content))
      @last_content_drawn = ctnt.size-1 + @current_content
      height = 0
      ctnt.each do |ctn|
        ctn.draw(height)
        height += ctn.height + 1
      end
      NCurses.print "Node: #{@content.size}, #{@current_content}, #{@last_content_drawn}", NCurses.height-1, 0
    end
  end
end