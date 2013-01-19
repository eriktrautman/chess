class Player
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def get_location
    choice = []
    until is_valid_input_style?(choice)
      print "> "
      choice = gets.chomp.split(',').map(&:to_i)
      puts "Choice: #{choice}"
      puts "INVALID INPUT. TRY AGAIN." unless is_valid_input_style?(choice)
    end
    choice
  end

  def is_valid_input_style?(player_input)
    player_input.length == 2 && player_input.all? { |num| (0..7).include?(num) } || player_input == [666]
  end

  #get input from player, check if it's in valid format
  #then check to make sure it's on the board
  #and check if the piece belongs to their color
end