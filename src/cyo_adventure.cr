require "ncurses"
require "w3m_image_display"
require "./cyo_adventure/*"

class CYOAdventure
  include Interactable

  BOOK_FILE_NAME = "book.txt"

  @nodes = {} of Int32 => Node

  @current_node = 0

  def initialize(path : String)
    path += BOOK_FILE_NAME if File.directory?(path)
    raise "Book #{path} does not exist" unless File.file?(path)
    File.read(path).split(/(?<=[^\\\\])#n|^#n/, remove_empty: true) do |node|
      @nodes[node.each_line.next.as(String).to_i32] = Node.new(self, node.split("\n", 2)[1], File.dirname(path))
    end
  end

  private def node : Node
    @nodes[@current_node]
  end

  protected def change_node(new : Int32)
    raise "Not a node" unless @nodes[new]?
    @current_node = new
  end

  def handle_key(key) : Bool
    case key
    when 'c' then NCurses.clear
    else
      return node.handle_key(key)
    end
    true
  end

  def handle_mouse(mouse) : Bool
    false
  end

  def loop
    loop do
      NCurses.clear
      node.draw
      NCurses.refresh
      Image.draw_cache
      case (key = NCurses.get_char)
      when 'q' then return
      when NCurses::Key::Resize then #resize
      when NCurses::Key::Mouse then handle_mouse(NCurses.get_mouse)
      else handle_key(key)
      end
    end
  end

  book = self.new("book/book.txt")

  NCurses.start
  NCurses.no_echo
  NCurses.cbreak
  NCurses.keypad true
  NCurses.mouse_mask(NCurses::Mouse::AllEvents | NCurses::Mouse::Position)

  book.loop

  NCurses.end

end
