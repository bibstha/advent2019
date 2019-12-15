require 'minitest/autorun'

max_x = 10
max_y = 10

base = [1, 1]
dst = [4, 5]

class AstroidBelt
  attr_reader :visible_counts

  def initialize(input)
    @coordinates = []
    input.map.with_index do |line, y|
      line.chars.each_with_index do |c, x|
        @coordinates << [x, y] if c == '#'
      end
    end

    @max_y = input.size
    @max_x = input.first.size
  end

  def calculate_visible_counts
    @visible_counts = {}
    @coordinates.each do |base|
      astroid = Astroid.new(base, @coordinates, @max_x, @max_y)
      visible_counts[base] = astroid.visible_neighbours_count
    end
  end

  def max_visibile_astroids
    @visible_counts.max_by { |xy, count| count }
  end
end

class Astroid
  def initialize(base, all_astroid_bases, max_x, max_y)
    @base = base
    @max_x = max_x
    @max_y = max_y
    @all_astroid_bases = all_astroid_bases
    compute_positions
  end

  def visible_neighbours_count
    @positions.count { |pos, visibility| visibility == true }
  end

  def compute_positions
    @positions = {}
    @all_astroid_bases.each do |x, y|
      next if [x, y] == @base
      next if @positions.key?([x, y]) # already seen this coordinate

      @positions[[x, y]] = true # mark coordinate as visible if does not already exist

      hidden_pts = calculate_hidden_pts([x, y])
      hidden_pts.each do |x1, y1|
        @positions[[x1, y1]] = false # mark coordinate as invisible
      end
    end
  end

  def slope_x_y(dst)
    x_drn = dst[0] >= @base[0] ? 1 : -1
    y_drn = dst[1] >= @base[1] ? 1 : -1

    begin
      slope_x_y = Rational(dst[1] - @base[1], dst[0] - @base[0])
      x_inc = slope_x_y.denominator.abs
      y_inc = slope_x_y.numerator.abs
    rescue ZeroDivisionError
      y_inc = 1
      x_inc = 0
    end
  end

  def calculate_hidden_pts(dst)
    pts = []

    x_drn = dst[0] >= @base[0] ? 1 : -1
    y_drn = dst[1] >= @base[1] ? 1 : -1

    begin
      slope_x_y = Rational(dst[1] - @base[1], dst[0] - @base[0])
      x_inc = slope_x_y.denominator.abs
      y_inc = slope_x_y.numerator.abs
    rescue ZeroDivisionError
      y_inc = 1
      x_inc = 0
    end

    x1 = dst[0]
    y1 = dst[1]

    loop do
      x1 += x_inc * x_drn
      y1 += y_inc * y_drn

      if x1 >= 0 && x1 < @max_x &&
        y1 >= 0 && y1 < @max_y

        pts << [x1, y1]
      else
        break
      end
    end

    pts
  end
end

class MyTest < Minitest::Test
  def test_example1
    input = File.readlines('input_eg1').each(&:chomp!)
    belt = AstroidBelt.new(input)
    belt.calculate_visible_counts
    assert_equal [[3, 4], 8], belt.max_visibile_astroids
  end

  def test_example2
    input = File.readlines('input_eg2').each(&:chomp!)
    belt = AstroidBelt.new(input)
    belt.calculate_visible_counts
    assert_equal [[5, 8], 33], belt.max_visibile_astroids
  end

  def test_example3
    input = File.readlines('input_eg3').each(&:chomp!)
    belt = AstroidBelt.new(input)
    belt.calculate_visible_counts
    assert_equal [[1, 2], 35], belt.max_visibile_astroids
  end

  def test_example4
    input = File.readlines('input_eg4').each(&:chomp!)
    belt = AstroidBelt.new(input)
    belt.calculate_visible_counts
    assert_equal [[6, 3], 41], belt.max_visibile_astroids
  end

  def test_example5
    input = File.readlines('input_eg5').each(&:chomp!)
    belt = AstroidBelt.new(input)
    belt.calculate_visible_counts
    assert_equal [[11, 13], 210], belt.max_visibile_astroids
  end

  def test_part1
    input = File.readlines('input').each(&:chomp!)
    belt = AstroidBelt.new(input)
    belt.calculate_visible_counts
    assert_equal [[22, 25], 286], belt.max_visibile_astroids
  end
end


