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

      start_coord = get_start_coordinates

      until valid_move?(start_coord, end_coord)
        puts "End coordinates"
        end_coord = @current_player.get_location

        # escape back to getting start coords with '[666]'
        start_coord = get_start_coordinates if end_coord == [666]
        p "End Coords: #{end_coord.inspect}"
      end

      execute_move(start_coord, end_coord)
      toggle_current_player
      print_board
    end
  end

  def get_start_coordinates
    start_coord = []
    until start_coord_valid?(start_coord)
      puts "Start coordinates"
      start_coord = @current_player.get_location
    end
    print_board(start_coord)
    puts "Move #{@board[start_coord[0]][start_coord[1]].class.to_s.upcase} where?"
    return start_coord
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

  def print_board(coords=[])
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
          if coords == [row,col]
            print "[#{UNICODE_CHARS[piece.name]}]"
          else
            print " #{UNICODE_CHARS[piece.name]} "
          end
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
  def execute_hypo_move(original_coords, test_coords)
    @piece_purgatory = @board[test_coords[0]][test_coords[1]]
    @board[test_coords[0]][test_coords[1]] = @board[original_coords[0]][original_coords[1]]
    @board[original_coords[0]][original_coords[1]] = nil
  end

  # Will undo a hypothetical move by bringing back any piece that is in purgatory
  def reverse_hypo_move(original_coords, test_coords)
    @board[original_coords[0]][original_coords[1]] = @board[test_coords[0]][test_coords[1]]
    @board[test_coords[0]][test_coords[1]] = @piece_purgatory
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
    return true unless valid_move_chain(start_coords, end_coords).empty?
    false
  end

  # takes a start coord pair and end coord pair, and returns the move chain between them if valid
  def valid_move_chain(start_coords, end_coords)
    valid_move_chain = []
    piece = @board[start_coords[0]][start_coords[1]]

    if piece.is_a?(Pawn)
      all_potential_moves = piece.theoretical_moves(start_coords[0], start_coords[1], @board)
    else
      all_potential_moves = piece.theoretical_moves(start_coords[0], start_coords[1])
    end

    intersecting_move_chain = all_potential_moves.select { |move_chain| move_chain.include?(end_coords) }.first
    return [] if intersecting_move_chain.nil?

    #otherwise, step through the move chain looking for obstacles or other issues
    intersecting_move_chain.each do |tile_coords|
      tile = @board[tile_coords[0]][tile_coords[1]]
      if tile_coords == end_coords && ( tile.nil? || tile.color != piece.color )
        valid_move_chain << tile_coords
        puts "MOVE CHAIN:: #{valid_move_chain.inspect}"
        return valid_move_chain
      elsif tile.nil?
        valid_move_chain << tile_coords
      else
        return []
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
      return true if checkmate?
      puts "...but not checkmate."
    end
    false
  end

  # determines if any of an opponent's pieces have a valid path to our king
  def check?
    king_coords = current_player_king_coordinates
    puts "king coords are: #{king_coords}"
    return true unless build_DANGER_moves_array.empty?
  end

  def build_DANGER_moves_array
    king_coords = current_player_king_coordinates
    danger_array = []
    8.times do |row|
      8.times do |col|
        tile = @board[row][col]
        if tile && tile.color != @current_player.color
          #puts "Found an enemy #{tile.class} piece at #{row}, #{col}!"
          valid_moves = valid_move_chain([row, col], king_coords)
          unless valid_moves.empty?
            #add threatening piece's position to start of danger_array
            valid_moves.unshift([row, col])
            danger_array << valid_moves
          end
        end
      end
    end
    puts "DANGER ARRAY: #{danger_array}"
    danger_array
  end

  def checkmate?
    danger_moves_array = build_DANGER_moves_array
    if danger_moves_array.size == 1
      return true unless escape_by_kill_or_block?(danger_moves_array) || move_king_escape?
    else
      return true unless move_king_escape?
    end
  end

  # Tests whether the king has a valid move that removes the check situation
  def move_king_escape?
    king_row, king_col = current_player_king_coordinates
    theo_moves = @board[king_row][king_col].theoretical_moves(king_row, king_col)
    theo_moves.each do |end_coords|
      if valid_move?([king_row, king_col], end_coords)
        # test check condition on its hypothetical self. If NOT check, return TRUE!!!
        execute_hypo_move([king_row, king_col], end_coords)
        if !check?
          puts "WE HAVE AN ESCAPE!!! End coords are: #{end_coords}"
          return true
        end
        reverse_hypo_move([king_row, king_col], end_coords)
      end
    end
    puts "No escape is possible..."
    false
  end

  # tests whether the player in check can block it by moving another piece to an intervening tile
  # or kill the threatening piece (without exposing a ------new check situation!!!!!!!!----)
  def escape_by_kill_or_block?(danger_array)
    8.times do |row|
      8.times do |col|
        tile = @board[row][col]
        if tile && tile.color == @current_player.color
          danger_array.first.each do |danger_tile|
            return true if valid_move?([row, col], danger_tile)
          end
        end
      end
    end
    puts "No kill or block options available..."
    false
  end


end

# NOTES
# Checkmate
  # Need to test that a kill or block will not expose king to another check
# prevent any piece from exposing a check situation
# commands: save, (something better than 666), load, etc
# broken pawns
# Illegal king escape move from check mate

# TODO
# YAML
# Pawns
# Test check/mate
# more checking for check as per notes, including the hypothetical moves




# SCRIPT

c = Chess.new
c.populate_board
c.print_board
c.play

#puts "OUTPUT: #{c.board[0][1].theoretical_moves(0, 1)}"