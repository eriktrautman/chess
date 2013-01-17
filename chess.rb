require "./chess_pieces.rb"
require "./chess_player.rb"

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
    populate_board
    @player1 = Player.new("white")
    @player2 = Player.new("black")
    @current_player = @player1
  end

  def play
    #play the game until checkmate/victory
    until game_over?

      start_coord = []
      end_coord = []

      until start_coord_valid?(start_coord)
        print "Start coordinates: "
        start_coord = @current_player.get_location
      end

      until valid_move?(start_coord, end_coord)
        print "End coordinates: "
        end_coord = @current_player.get_location
      end

      execute_move(start_coord, end_coord)
      toggle_current_player
    end
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
    puts
  end

  def execute_move(from_coord, to_coord)
    @board[to_coord[0]][to_coord[1]] = @board[from_coord[0]][from_coord[1]]
    @board[from_coord[0]][from_coord[1]] = nil
  end

  def start_coord_valid?(coordinates)
    # No stupid stuff... is it my piece?
    piece = @board[coordinates[0]][coordinates[1]]
    if piece.nil?
      puts "NO PEACE \u262E"
      return false
    elsif piece.color != @current_player.color
      puts "Not yo' color!"
      return false
    else
      true
    end
  end

  def valid_move?(start_coords, end_coords)
    piece = @board[start_coords[0]][start_coords[1]]
    # Ask peace for its theoretical moves
    theoretical_moves = piece.theoretical_moves(start_coords[0], start_coords[1])

    # is the end point included in them at all
    #if so, make new array with just that one
    move_seq = theoretical_moves.select { |sub_a| sub_a.include?(end_coords) }.first
    return false if move_seq.size == 0

    move_seq.each do |tile_coords|
      tile = @board[tile_coords[0]][tile_coords[1]]
      if tile_coords == end_coords
        if tile.nil?
          return true
        elsif tile.color != @current_player.color
          return true
        else
          return false
        end
      elsif !tile.nil?
        return false
      end
    end
  end

  def toggle_current_player
    @current_player = @current_player == @player1 ? @player2 : @player1
  end

  def game_over?
    false
  end

end

# SCRIPT

c = Chess.new
c.populate_board
c.print_board

puts "OUTPUT: #{c.board[0][1].theoretical_moves(0, 1)}"