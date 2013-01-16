# Adam and Erik
# 1/16/13

class Piece
#ask ned about way to change attrs to attr?
  BOARD_LENGTH = 8

  attr_accessor :moved
  attr_reader :color

  alias_method :moved?, :moved

  def initialize(color)
    @color = color
    @moved = false
  end

  def name
    @color + self.class.to_s
  end

  def in_bounds?(coordinate)
    coordinate >= 0 && coordinate < BOARD_LENGTH
  end

  def theoretical_moves(start_row, start_column, max)
    theoretical_moves = []
    row, column = start_row, start_column

    self.moves.each do |move_coord|
      move_chain = []
      while in_bounds?(row + move_coord[0]) && in_bounds?(column + move_coord[1])
        move_chain << [row + move_coord[0], column + move_coord[1]]
      end
      theoretical_moves << move_chain
    end
  end

end



class King < Piece
   = [[-2, 0], [1, 0], [0, -1], [0, 1]]
end

class Queen < Piece

end

class Rook < Piece
  attr_reader :moves, :max_distance

  def initialize(color)
    super(color)
    @moves = [[-1, 0], [1, 0], [0, -1], [0, 1]]
    @max_distance = 8
  end
end

class Bishop < Piece

end

class Knight < Piece

end

class Pawn < Piece

end
