require "./chess_pieces.rb"

class Chess

  UNICODE_CHARS = {
    "whiteKing" => "\u2654",
    "whiteQueen" => "\u2655",
    "whiteRook" => "\u2656",
    "whiteBishop" => "\u2657",
    "whiteKnight" => "\u2658",
    "whitePawn" => "\u2659",
    "blackKing" => "\u265A",
    "blackQueen" => "\u265B",
    "blackRook" => "\u265C",
    "blackBishop" => "\u265D",
    "blackKnight" => "\u265E",
    "blackPawn" => "\u265F"
  }

  attr_reader :board

  def initialize
    @board = []
    build_board
  end

  def build_board
    8.times do
      tmp = []
      8.times do
        tmp << nil
      end
      @board << tmp
    end
  end

  def populate_board
    @board[0], @board[1] = populate_side("white")

    black_setup = populate_side("black")
    @board[7], @board[6] = black_setup[0].reverse, black_setup[1]
    nil
    # create and put pieces in appropriate positions
    #pieces for black & white
  end

  def populate_side(color)
    first_row = [
      Rook.new(color),
      Knight.new(color),
      Bishop.new(color),
      King.new(color),
      Queen.new(color),
      Bishop.new(color),
      Knight.new(color),
      Rook.new(color)
    ]
    second_row = []
    8.times { second_row << Pawn.new(color) }
    [first_row, second_row]
  end

  def print_board
    # cycle through the board, outputting " * " for nil and unicode for each piece otherwise
    print "  "
    ("A".."H").each { |char| print " #{char} " }
    puts
    8.times do |row|
      print "#{row} "
      8.times do |col|
        piece = @board[row][col]
        if piece.nil?
          print " * "
        else
          print " #{UNICODE_CHARS[piece.name]} "
        end
      end
      puts
    end
  end

  def execute_move(from_coord, to_coord)
    @board[to_coord[0]][to_coord[1]] = @board[from_coord[0]][from_coord[1]]
    @board[from_coord[0]][from_coord[1]] = nil
  end


end

# SCRIPT

c = Chess.new
c.populate_board
c.print_board
c.execute_move([1, 0], [2, 0])
c.print_board