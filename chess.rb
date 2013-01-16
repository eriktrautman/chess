require 'chess_pieces'

class Chess

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
    # create and put pieces in appropriate positions
    #pieces for black & white
  end

end