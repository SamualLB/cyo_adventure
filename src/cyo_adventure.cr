require "ncurses"
require "w3m_image_display"
require "./cyo_adventure/*"

class CYOAdventure
  include Interactable

  VERSION = "0.2.0"

  BOOK_FILE_NAME = "book.cyo"

  @nodes = {} of Int32 => Node

  @current_node = 0
  @node_cache = [] of Int32

  def initialize(path : String)
    path = Path.new(path, BOOK_FILE_NAME) if File.directory?(path)
    raise "Book #{path} does not exist" unless File.file?(path)
    File.read(path).split(/(?<=[^\\\\])#n|^#n/, remove_empty: true) do |node|
      @nodes[node.each_line.next.as(String).to_i32] = Node.new(self, node.split("\n", 2)[1], File.dirname(path))
    end
  end

  private def node : Node
    @nodes[@current_node]
  end

  protected def advance_node(new : Int32)
    raise "Not a node" unless @nodes[new]?
    @node_cache << @current_node
    @current_node = new
  end

  protected def retreat_node
    old = @node_cache.pop?
    @current_node = old if old
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
    node.handle_mouse(mouse)
  end

  def loop
    loop do
      NCurses.clear
      NCurses.print "#{@current_node}", NCurses.height-1, NCurses.width-3
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

  book = self.new("book")

  NCurses.start
  NCurses.no_echo
  NCurses.cbreak
  NCurses.keypad true
  NCurses.set_cursor(NCurses::Cursor::Invisible)
  NCurses.mouse_mask(NCurses::Mouse::AllEvents | NCurses::Mouse::Position)

  book.loop

  NCurses.end

end
