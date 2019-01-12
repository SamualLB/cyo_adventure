class CYOAdventure
  abstract class Content

    getter! node : Node

    def next : Content?
      
    end

    # Dispatch to correct class
    #
    # ```text
    # #i54
    # ```
    #
    # Should create an image finding the file with name '54'
    #
    # ```text
    # #c32 Jump
    # ```
    #
    # Should create a choice with the text 'Jump' leading to node 32
    def self.new(node : Node, line : String, dir : String) : Content
      (iter = line.each_char).next
      case iter.next
      when 'e'
        Ending.new(node)
      when 'i'
        Image.new(node, line, dir)
      when 'c'
        Choice.new(node, line)
      else
        raise "Unrecognised content #{line}"
      end
    end

    abstract def height : Int32

    abstract def draw(offset : Int32, height : Int32)

    abstract def new_line : Bool
  end
end
