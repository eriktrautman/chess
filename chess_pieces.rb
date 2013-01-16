# Adam and Erik
# 1/16/13

class Piece
#ask ned about way to change attrs to attr?
  BOARD_LENGTH = 8
  DIAGONALS = [[-1,-1],[-1,1],[1,1],[1,-1]]
  LEFT_RIGHT = [[1,0],[-1,0]]
  FWD_BACK = [[0,1],[0-1]]
  KNIGHT = [[-2,1],[-2,-1],[-1,2],[-1,-2],[1,2],[1,-2],[2,1],[2,-1]]

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

  def in_bounds?(coordinates)
    (0..BOARD_LENGTH-1).include?(coordinates[0] && coordinates[1])
  end

  # outputs an array containing subarrays of theoretical moves (in order outwards)
  def theoretical_moves(start_row, start_column)
    theoretical_moves = []
    row, column = start_row, start_column

    self.moves.each do |move_coord|
      move_chain = []
      while in_bounds?([row + move_coord[0],column + move_coord[1]]) && move_chain.size < self.max_distance
        move_chain << [row + move_coord[0], column + move_coord[1]]
      end
      theoretical_moves << move_chain
    end
  end

end

# ------------------------------------------------------------------------------------

class King < Piece
  attr_reader :moves, :max_distance

  def initialize(color)
    super(color)
    @moves = LEFT_RIGHT + FWD_BACK + DIAGONALS
    @max_distance = 1
  end
end

class Queen < Piece
  attr_reader :moves, :max_distance

  def initialize(color)
    super(color)
    @moves = LEFT_RIGHT + FWD_BACK + DIAGONALS
    @max_distance = 8
  end
end

class Rook < Piece
  attr_reader :moves, :max_distance

  def initialize(color)
    super(color)
    @moves = LEFT_RIGHT + FWD_BACK
    @max_distance = 8
  end
end

class Bishop < Piece
  attr_reader :moves, :max_distance

  def initialize(color)
    super(color)
    @moves = DIAGONALS
    @max_distance = 8
  end
end

class Knight < Piece
  attr_reader :moves, :max_distance

  def initialize(color)
    super(color)
    @moves = KNIGHT
    @max_distance = 1
  end
end

class Pawn < Piece
  # GRRRRRR
end
