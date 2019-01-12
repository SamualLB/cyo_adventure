class CYOAdventure
  module Interactable
    abstract def handle_key(key) : Bool

    abstract def handle_mouse(mouse : NCurses::MouseEvent) : Bool
  end
end