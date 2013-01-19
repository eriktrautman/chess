require './chess.rb'

describe Chess do
  subject(:chessgame) {Chess.new}

  its(:board) { should_not be_nil }

  # QUESTION ::: Can this line be written using the above its() syntax?? seems cleaner...
  it "should start with white as current player" do
    chessgame.current_player.color.should eq("white")
  end

  describe "piece movement" do
    it "should not allow pieces to move through other pieces" do
      chessgame.valid_move?([0,0], [7, 0]).should be(false)
    end

    it "should allow pieces to move to empty squares with open move path" do
      chessgame.valid_move?([1,0], [3,0]).should be(true) # pawn
    end

    it "should not allow pieces to take pieces of their own color" do
      chessgame.valid_move?([0,0], [1,0]).should be(false)
    end

    describe "should only allow pieces to move with their movement type" do
      it "pawns" do
        chessgame.valid_move?([1,0], [4,0]).should be(false)
        chessgame.valid_move?([1,0], [2,0]).should be(true)
        chessgame.valid_move?([1,0], [2,1]).should be(false)
      end

      it "knights" do
        chessgame.valid_move?([0,1], [2,0]).should be(true)
        chessgame.valid_move?([0,1], [2,1]).should be(false)
      end

      #... etc

    end

    it "should allow pieces to take pieces of the opposite color" do
      chessgame.board = []
      chessgame.build_board
      chessgame.board[0][0] = Rook.new("white")
      chessgame.board[7][0] = Rook.new("black")
      chessgame.print_board
      chessgame.valid_move?([0,0], [7,0]).should be_true
    end

  end

  describe "check / checkmate" do

    before do
      chessgame.board = []
      chessgame.build_board
      chessgame.board[0][7] = King.new("white")
      chessgame.board[2][7] = Queen.new("black")
    end

    describe "check" do
      it "is properly identified" do
        chessgame.print_board
        chessgame.check?.should be_true
      end

      it "will identify moves that cause check" do
        chessgame.board[1][7] = Rook.new("white")
        chessgame.print_board
        chessgame.move_causes_check?([1,7],[1,6]).should be_true
      end

      it "will identify moves that do not cause check" do
        chessgame.board[1][7] = Rook.new("white")
        chessgame.board[0][0] = Rook.new("white")
        chessgame.print_board
        chessgame.move_causes_check?([0,0],[7,0]).should be_false
      end
    end

    describe "checkmate" do
      it "is not declared if the king can escape" do
        chessgame.print_board
        chessgame.checkmate?.should be_false
      end

      it "is not declared if the offending piece can be killed (by any piece)" do
        chessgame.board[1][6] = Rook.new("black")
        chessgame.board[2][5] = Rook.new("white")
        chessgame.print_board
        chessgame.checkmate?.should be_false
      end

      it "is not declared if another piece can block check" do
        chessgame.board[1][6] = Rook.new("white")
        chessgame.print_board
        chessgame.checkmate?.should be_false
      end

      it "properly identifies checkmate" do
        chessgame.board[1][6] = Rook.new("black")
        chessgame.print_board
        chessgame.checkmate?.should be_true
      end

    end


  end
end