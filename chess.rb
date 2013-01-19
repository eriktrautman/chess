require "./chess_pieces.rb"
require "./chess_player.rb"
require 'yaml'

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

  # Only added access to these to test RSpec... is there a better way to test them
  # than making them accessible like that???
  # Should just be attr_reader :board
  attr_accessor :board, :current_player

  def initialize
    @board = []
    build_board
    populate_board
    @player1 = Player.new("white")
    @player2 = Player.new("black")
    @current_player = @player1
  end

  def play
    print_board

    until game_over?
      puts "It's your turn, #{@current_player.color} Player!"
      puts "Coordinate format is Y,X (eg 1, 0)"
      puts "'save' to save, 'quit' to quit, or 'reset' to switch pieces"
      start_coord = []
      end_coord = []
      start_coord = get_start_coordinates

      until valid_move?(start_coord, end_coord) && !move_causes_check?(start_coord, end_coord)
        puts "END COORDINATES"
        end_coord = @current_player.get_user_input

        # allow player to switch pieces by typing 'reset'
        start_coord = get_start_coordinates if do_special_input_stuff(end_coord) == "reset"
      end

      execute_move(start_coord, end_coord)
      toggle_current_player
      print_board
    end
  end


  # <<<<<<<<<<<<<<<<<<<< INPUT METHODS >>>>>>>>>>>>>>>>>>>>>>

  #terrible, terrible input handling - a relic of a much simpler version of the game
  #learning so many lessons about big projects here.
  def do_special_input_stuff(input)
    case input
    when "save"
      save
      []
    when "reset"
      puts "Choose different piece:"
      "reset"
    when "quit"
      puts "QUITTING"
      exit
    else
      false
    end
  end

  # why does this happen somewhere other than end coordinates?
  def get_start_coordinates
    start_coord = []
    until start_coord_valid?(start_coord)
      puts "START COORDINATES"
      start_coord = @current_player.get_user_input
      start_coord = [] if ["reset", "save", []].include?(do_special_input_stuff(start_coord)) #hackhackhack
    end
    print_board(start_coord)
    puts "Move #{@board[start_coord[0]][start_coord[1]].class.to_s.upcase} where?"
    return start_coord
  end

  # <<<<<<<<<<<<<<<<<<<< INITIALIZATION METHODS >>>>>>>>>>>>>>>>>>>>>>

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
    (0..7).each { |char| print " #{char} " }
    print " << X COORDINATE"
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
    puts "^ Y COORDINATE"
    puts
  end

  def toggle_current_player
    @current_player = @current_player == @player1 ? @player2 : @player1
  end

  # <<<<<<<<<<<<<<<<<<<< MOVEMENT METHODS >>>>>>>>>>>>>>>>>>>>>>

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


  # <<<<<<<<<<<<<<<<<<<< MOVE VALIDATION METHODS >>>>>>>>>>>>>>>>>>>>>>

  def start_coord_valid?(coordinates)
    return false if coordinates.empty?

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
        return valid_move_chain
      elsif tile.nil?
        valid_move_chain << tile_coords
      else
        return []
      end
    end
  end

  def move_causes_check?(start_coords, end_coords)
    execute_hypo_move(start_coords, end_coords)
    if check?
      reverse_hypo_move(start_coords, end_coords)
      puts "STOP! That move will get you killed!"
      return true
    end
    reverse_hypo_move(start_coords, end_coords)
    false
  end

  # <<<<<<<<<<<<<<<<<<<< GAME OVER METHODS >>>>>>>>>>>>>>>>>>>>>>

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
      next if end_coords.empty?
      if valid_move?([king_row, king_col], end_coords[0])

        # test check condition on its hypothetical board one move in advance. If NOT check, return TRUE!!!
        execute_hypo_move([king_row, king_col], end_coords[0])
        if !check?
          puts "WE HAVE AN ESCAPE!!! End coords are: #{end_coords}"
          reverse_hypo_move([king_row, king_col], end_coords[0])
          return true
        end
        reverse_hypo_move([king_row, king_col], end_coords[0])

      end
    end
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
            #puts "testing kill/block for #{tile.class} from #{row},#{col} to #{danger_tile}!!!"
            if valid_move?([row, col], danger_tile)
              execute_hypo_move([row, col], danger_tile)
              if !check?
                puts "We have a possible kill/block move with #{tile.class}!!!"
                reverse_hypo_move([row, col], danger_tile)
                return true
              end
              reverse_hypo_move([row, col], danger_tile)
            end
          end
        end
      end
    end
    false
  end


  # <<<<<<<<<<<<<<<<<<<< FILE OPERATIONS >>>>>>>>>>>>>>>>>>>>>>

  def save
    puts "Save file as:"
    filename = gets.chomp

    File.open(filename, 'w') do |f|
      YAML.dump(self, f)
    end
  end

end


  # <<<<<<<<<<<<<<<<<<<< BEGIN GAME SCRIPT >>>>>>>>>>>>>>>>>>>>>>

if $PROGRAM_NAME == __FILE__

  case ARGV.count
  when 0
    Chess.new.play
  when 1
    YAML.load_file(ARGV.shift).play
  end
end
