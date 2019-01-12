class CYOAdventure
  class Node
    include Interactable

    @content = [] of Content
    @content_index = 0

    @choices = [] of Choice
    getter ending : Ending? = nil

    @pages = Array(Array(Content)).new
    @page_index = 0

    @choice : Choice?
    @choice_index = 0

    def initialize(@book : CYOAdventure, text : String, dir : String)
      text.each_line do |line|
        if line.starts_with?('#')
          @content << Content.new(self, line, dir)
        else
          @content << Text.new(self, line)
        end
      end
      @content.each { |ctnt| @choices << ctnt if ctnt.is_a?(Choice) }
      @ending = @content[@content.size-1].as(Ending) if @content[@content.size-1].is_a?(Ending)
      @choice = @choices[@choice_index]?
      @choice.as(Choice).selected = true if @choice
    end

    def page : Array(Content)
      @pages[@page_index]
    end

    def content : Content
      @content[@content_index]
    end

    # Go forward in book
    def advance_content
      if @page_index+1 >= @pages.size
        # next node
        @book.advance_node @choice.as(Choice).@destination if @choice
      else
        @page_index += 1
      end
    end

    # Go back in book
    def retreat_content
      if @page_index <= 0
        @book.retreat_node
      else
        @page_index -= 1
      end
    end

    def choice_up
      return unless @choice
      return unless @choice_index-1 >= 0
      @choice.as(Choice).selected = false
      @choice = @choices[@choice_index -= 1]
      @choice.as(Choice).selected = true
    end

    def choice_down
      return unless @choice
      return unless @choice_index+1 < @choices.size
      @choice.as(Choice).selected = false
      @choice = @choices[@choice_index += 1]
      @choice.as(Choice).selected = true
    end

    def handle_key(key) : Bool
      case key
      when NCurses::Key::Right then advance_content
      when NCurses::Key::Left then retreat_content
      when NCurses::Key::Up then choice_up
      when NCurses::Key::Down then choice_down
      else return false 
      end
      true
    end

    def handle_mouse(mouse) : Bool
      false
    end

    # Build from the end
    def build_pages
      @pages.clear
      page = [] of Content
      images_on_page = [] of Image
      height = 0
      max_height = NCurses.height
      previous_content : Content? = nil
      @content.reverse.each do |cont|
        height += 1 if !cont.is_a?(Ending) && previous_content.is_a?(Ending)
        case cont
        when Ending
          page << cont
        when Choice
          page << cont
          height += 1
        when Image
          if max_height < height + max_height * 0.25 + 1
            unless images_on_page.empty?
              add_on = (max_height - height) / images_on_page.size
              images_on_page.each { |i| i.height = i.height + add_on }
            end
            @pages << page.reverse
            page = [] of Content
            images_on_page.clear
            height = 0
          end
          page << cont
          images_on_page << cont.as(Image)
          img_h = max_height * 0.25 + 1
          height += img_h
          cont.height = img_h
        when Text
          if max_height < height + content.height + 1
            unless images_on_page.empty?
              add_on = (max_height - height) / images_on_page.size
              images_on_page.each { |i| i.height = i.height + add_on }
            end
            @pages << page.reverse
            page = [] of Content
            images_on_page.clear
            height = 0
          end
          page << cont
          height += cont.height + 1
        end
        previous_content = cont
      end
      unless images_on_page.empty?
        add_on = (max_height - height) / images_on_page.size
        images_on_page.each { |i| i.height = i.height + add_on }
      end
      @pages << page.reverse
      @pages.reverse!
    end

    def draw
      build_pages if @pages.empty?
      draw_content(page)
    end

    private def draw_content(ctnt : Array(Content))
      height = 0
      ctnt.each do |ctn|
        ctn.draw(height)
        height += ctn.height
        height += 1 if ctn.new_line
      end
    end
  end
end