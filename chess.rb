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
      puts "It's your turn, #{@current_player.color} Player!"
      start_coord = []
      end_coord = []

      until start_coord_valid?(start_coord)
        puts "Start coordinates"
        start_coord = @current_player.get_location
      end
      puts "Move #{@board[start_coord[0]][start_coord[1]].class.to_s.upcase} where?"

      until valid_move?(start_coord, end_coord)
        puts "End coordinates"
        end_coord = @current_player.get_location
        p "End Coords: #{end_coord.inspect}"
      end

      execute_move(start_coord, end_coord)
      toggle_current_player
      print_board
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

  def execute_move(from_coords, to_coords)
    @board[to_coords[0]][to_coords[1]] = @board[from_coords[0]][from_coords[1]]
    @board[from_coords[0]][from_coords[1]] = nil
  end

  # Will execute a move in such a way that it is reversible
  # by storing any piece that was killed off to the side in 'purgatory'
  def execute_hypo_move(from_coords, to_coords)
    @piece_purgatory = @board[to_coords[0]][to_coords[1]]
    @board[to_coords[0]][to_coords[1]] = @board[from_coords[0]][from_coords[1]]
    @board[from_coords[0]][from_coords[1]] = nil
  end

  # Will undo a hypothetical move by bringing back any piece that is in purgatory
  def reverse_hypo_move(from_coords, to_coords)
    @board[from_coords[0]][from_coords[1]] = @board[to_coords[0]][to_coords[1]]
    @board[to_coords[0]][to_coords[1]] = @piece_purgatory
    @piece_purgatory = nil
  end

  def start_coord_valid?(coordinates)
    return false if coordinates.size == 0

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

  # checks if the piece sitting at those start coordinates can make a valid
  # and unobstructed path to an open square or enemy piece at the end coordinates
  def valid_move?(start_coords, end_coords)
    return false if end_coords.size == 0 # validate user input

    piece = @board[start_coords[0]][start_coords[1]]
    #puts "In valid_move, piece is a #{piece.class}"

    if piece.is_a?(Pawn)
      theoretical_moves = piece.theoretical_moves(start_coords[0], start_coords[1], @board)
    else
      theoretical_moves = piece.theoretical_moves(start_coords[0], start_coords[1])
    end

    # pull out any theoretical move sequence that actually crosses our end coordinates
    move_seq = theoretical_moves.select { |sub_a| sub_a.include?(end_coords) }.first
    puts "#{piece.class} move sequence is #{move_seq.inspect}"
    return false if move_seq.nil?

    # check to make sure there are no obstructions and end point is empty or enemy
    move_seq.each do |tile_coords|
      tile = @board[tile_coords[0]][tile_coords[1]]
      if tile_coords == end_coords
        if tile.nil?
          return true
        elsif tile.color != piece.color
          return true
        else
          return false
        end
      elsif !tile.nil?
        return false
      end
    end
  end

  def current_player_king_coordinates
    8.times do |row|
      8.times do |col|
        tile = @board[row][col]
        if tile && tile.color == @current_player.color && tile.is_a?(King)
          return [row, col]
        end
      end
    end
  end


  def toggle_current_player
    @current_player = @current_player == @player1 ? @player2 : @player1
  end

  def game_over?
    if check?
      puts "You're in check!"
      return true
      #return true if checkmate?
    end
    puts "NOT IN CHECK"
    false
  end

  # determines if any of an opponent's pieces have a valid path to our king
  def check?
    king_coords = current_player_king_coordinates
    puts "king coords are: #{king_coords}"

    8.times do |row|
      8.times do |col|
        tile = @board[row][col]
        if tile && tile.color != @current_player.color
          #puts "Found an enemy #{tile.class} piece at #{row}, #{col}!"
          return true if valid_move?([row, col], king_coords)
        end
      end
    end
    false
  end

  def checkmate?
    false
  end

end

# NOTES
# Infinite loop if choosing piece with no possible moves
# Check
# Checkmate
  # Danger ZOOOOOOOONE!!!!
# simple commands, eg. quit, save, change piece




# SCRIPT

c = Chess.new
c.populate_board
c.print_board
c.play

#puts "OUTPUT: #{c.board[0][1].theoretical_moves(0, 1)}"