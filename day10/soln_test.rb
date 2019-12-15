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

    @astroids = @coordinates.map do |base|
      astroid = Astroid.new(base, @coordinates, @max_x, @max_y)
    end
  end

  def base
    @base ||= @astroids.max_by { |astroid| astroid.visible_astroid_count }
  end
end

class Astroid
  attr_reader :visible_astroid_count

  def initialize(base, all_astroid_bases, max_x, max_y)
    @base = base
    @max_x = max_x
    @max_y = max_y
    @all_astroid_bases = all_astroid_bases
    @other_astroid_bases = all_astroid_bases - [base]
    compute_positions
  end

  def part1_to_a
    [@base, @visible_astroid_count]
  end

  def compute_positions
    @positions = {}
    @other_astroid_bases.each do |x, y|
      next if @positions.key?([x, y]) # already seen this coordinate

      @positions[[x, y]] = true # mark coordinate as visible if does not already exist

      hidden_pts = calculate_hidden_pts([x, y])
      hidden_pts.each do |x1, y1|
        @positions[[x1, y1]] = false # mark coordinate as invisible
      end
    end
    @visible_astroid_count = @positions.count { |pos, visibility| visibility == true }
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

    [x_inc * x_drn, y_inc * y_drn]
  end

  def calculate_hidden_pts(dst)
    pts = []

    x1 = dst[0]
    y1 = dst[1]

    x_slope, y_slope = slope_x_y(dst)

    loop do
      x1 += x_slope
      y1 += y_slope

      if x1 >= 0 && x1 < @max_x &&
        y1 >= 0 && y1 < @max_y

        pts << [x1, y1]
      else
        break
      end
    end

    pts
  end

  def grouped_neighbours
    a = @other_astroid_bases.group_by do |dst|
      slope_x_y(dst)
    end.transform_values! do |destinations|
      destinations.sort_by { |dst_x, dst_y| (dst_x - @base[0]).abs + (dst_y - @base[1]).abs }
    end

    # p a
    # p "HELLO"
    b = a.sort_by do |slope_xy, destinations|
      tan_x = slope_xy[1] # take y as tan_x
      tan_y = slope_xy[0] # take x as tan_y
      # rotate coordinate such that (x, y) = (y, -x) for clockwise 90 degree

      angle = -1 * Math.atan2(tan_y, tan_x)
    end.to_h

    astroid_positions = b.values

    count = 1
    value = nil
    loop do
      positions = astroid_positions.shift
      break if positions.nil?

      value = positions.shift

      puts "Position #{count} value #{value}"

      astroid_positions << positions unless positions.empty?
      count += 1
    end
    # b.each do |slope_xy, destinations|
    #   destinations.
    # end
    # p b
    # b.each do |x, y|
    #   # if y.size > 1
    #     p x
    #     p y
    #     puts "HELLO"
    #   # end
    # end
  end
end

class MyTest < Minitest::Test
  def test_example1
    input = File.readlines('input_eg1').each(&:chomp!)
    belt = AstroidBelt.new(input)
    base = belt.base
    assert_equal [[3, 4], 8], base.part1_to_a
  end

  def test_example2
    input = File.readlines('input_eg2').each(&:chomp!)
    belt = AstroidBelt.new(input)
    assert_equal [[5, 8], 33], belt.base.part1_to_a
  end

  def test_example3
    input = File.readlines('input_eg3').each(&:chomp!)
    belt = AstroidBelt.new(input)
    assert_equal [[1, 2], 35], belt.base.part1_to_a
  end

  def test_example4
    input = File.readlines('input_eg4').each(&:chomp!)
    belt = AstroidBelt.new(input)
    assert_equal [[6, 3], 41], belt.base.part1_to_a
  end

  def test_example5
    input = File.readlines('input_eg5').each(&:chomp!)
    belt = AstroidBelt.new(input)
    assert_equal [[11, 13], 210], belt.base.part1_to_a
  end

  def test_part1
    input = File.readlines('input').each(&:chomp!)
    belt = AstroidBelt.new(input)
    assert_equal [[22, 25], 286], belt.base.part1_to_a
  end

  def test_example6
    input = File.readlines('input_eg6').each(&:chomp!)
    belt = AstroidBelt.new(input)
    base = belt.base
    p base.part1_to_a
    base.grouped_neighbours
  end

  def test_example7
    input = File.readlines('input_eg5').each(&:chomp!)
    belt = AstroidBelt.new(input)
    base = belt.base
    p base.part1_to_a
    base.grouped_neighbours
    # prints 200 [8, 2]
  end

  def test_part2
    input = File.readlines('input').each(&:chomp!)
    belt = AstroidBelt.new(input)
    base = belt.base
    p base.part1_to_a
    base.grouped_neighbours
    # prints 200th element as 5,4 (Answer is 504)
  end
end


