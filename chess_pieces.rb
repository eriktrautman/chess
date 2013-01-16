# Adam and Erik
# 1/16/13

class Piece
#ask ned about way to change attrs to attr?
  attr_accessor :x_coord, :y_coord, :dead, :moved
  attr_reader :color

  alias_method :dead?, :dead
  alias_method :moved?, :moved

  def initialize(color)
    @color = color
    @dead = false
    @moved = false
  end

  def name
    @color + self.class.to_s
  end

end
