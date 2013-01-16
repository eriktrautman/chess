# Adam and Erik
# 1/16/13

class Piece
#ask ned about way to change attrs to attr?
  attr_accessor :x_coord, :y_coord, :moved
  attr_reader :color

  alias_method :moved?, :moved

  def initialize(color)
    @color = color
    @moved = false
  end

  def name
    @color + self.class.to_s
  end

end

class King < Piece

end

class Queen < Piece

end

class Rook < Piece

end

class Bishop < Piece

end

class Knight < Piece

end

class Pawn < Piece

end
