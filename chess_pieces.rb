# Adam and Erik
# 1/16/13

class Piece

  attr_accessor :x_coord, :y_coord, :dead, :moved
  attr_reader :color

  def initialize(x_coord, y_coord, board, color)
    @x_coord, @y_coord, @board, @color = x_coord, y_coord, board, color
    @dead = false
    @moved = false

  end

end
