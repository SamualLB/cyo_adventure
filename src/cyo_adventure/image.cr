class CYOAdventure
  class Image < Content

    EXTENSIONS = ["png", "jpg", "jpeg"]

    @@draw_cache = [] of {Image, Int32, Int32}

    @w3m_image : W3MImageDisplay::Image

    @cache_size : {Int32, Int32}? = nil

    @height = 3

    def initialize(@node : Node, hash_line : String, dir : String)
      file_name = hash_line.split("#i", remove_empty: true)[0]
      raise "#{dir} directory does not exist" unless File.directory?(dir)
      full_file_name : String? = nil
      Dir.entries(dir).each do |entry|
        EXTENSIONS.each do |ext|
          full = "#{dir}#{File::SEPARATOR}#{file_name}.#{ext}"
          if "#{dir}#{File::SEPARATOR}#{entry}" == full
            full_file_name = full 
            break
          end
        end
      end
      raise "Image #{hash_line} not found" unless full_file_name
      @w3m_image = W3MImageDisplay::Image.new(File.real_path(full_file_name))
    end

    def pixel_size
      @cache_size || (@cache_size = @w3m_image.size)
    end

    def height : Int32
      @height
    end

    def height=(new_h)
      @height = new_h.to_i32
    end

    # Store in a cache to be draw after the NCurses refresh
    def draw(offset : Int32 = 0, height = @height)
      @@draw_cache << {self, offset, height}
    end

    # Empty cache
    def self.draw_cache
      @@draw_cache.each do |tup|
        tup[0].@w3m_image.draw(0, tup[1], W3MImageDisplay.width, tup[2]).sync.sync_communication
      end
      @@draw_cache.clear
    end

    def new_line : Bool
      true
    end
  end
end
