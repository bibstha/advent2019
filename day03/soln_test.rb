require 'minitest/autorun'
require 'minitest/pride'

class Solution
  def initialize(lines)
    @line1, @line2 = lines
    @points = Hash.new { |h, k| h[k] = Hash.new(nil) }
    mark_map
  end

  def part1
    p1_shortest_distance
  end

  def part2
    p2_number_of_steps
  end

  private

  def mark_map
    mark_line(@line1, 1)
    mark_line(@line2, 2)
  end

  def mark_line(line, type)
    x, y = 0, 0
    line.each do |direction|
      distance = direction[1..-1].to_i
      if direction[0] == "R"
        (1..distance).each do |i|
          x = x + 1
          set(x, y, type)
        end
      elsif direction[0] == "L"
        (1..distance).each do |i|
          x = x - 1
          set(x, y, type)
        end
      elsif direction[0] == "U"
        (1..distance).each do |i|
          y = y + 1
          set(x, y, type)
        end
      elsif direction[0] == "D"
        (1..distance).each do |i|
          y = y - 1
          set(x, y, type)
        end
      end
    end
  end

  def set(x, y, type)
    if @points[x][y] && @points[x][y] != type
      @points[x][y] = 'X'
    else
      @points[x][y] = type
    end
  end

  def p1_shortest_distance
    shortest_distance = Float::INFINITY
    each_crossings do |i, j|
      manhattan_dist = i.abs + j.abs
      if shortest_distance > manhattan_dist
        shortest_distance = manhattan_dist
      end
    end
    shortest_distance
  end

  def p2_number_of_steps
    shortest_steps = Float::INFINITY
    each_crossings do |i, j|
      # total = traverse(@line1, i, j) +
      #   traverse(@line2, i, j)
      total = traverse_optimized(@line1, i, j) +
        traverse_optimized(@line2, i, j)

      if shortest_steps > total
        shortest_steps = total
      end
    end
    shortest_steps
  end

  def each_crossings(&blk)
    @points.each do |i, hash|
      hash.each do |j, type|
        if type == 'X'
          blk.call(i, j)
        end
      end
    end
  end

  def traverse_optimized(line, dst_x, dst_y)
    total_steps = 0
    x, y = 0, 0
    x1, y1 = 0, 0
    line.each do |direction|
      distance = direction[1..-1].to_i
      dir = direction[0]
      if dir == "R"
        x1 = x + distance
      elsif dir == "L"
        x1 = x - distance
      elsif dir == "U"
        y1 = y + distance
      elsif dir == "D"
        y1 = y - distance
      end

      if in_line?(x, y, x1, y1, dst_x, dst_y)
        total_steps += (dst_x - x).abs + (dst_y - y).abs
        return total_steps
      else
        total_steps += distance
      end

      x = x1
      y = y1
    end
  end

  def in_line?(x, y, x1, y1, dst_x, dst_y)
    if y == y1 && y == dst_y
      (x1 - x).abs >= (dst_x - x).abs &&
        (x1 - x).abs >= (x1 - dst_x).abs
    elsif x == x1 && x == dst_x
      (y1 - y).abs >= (dst_y - y).abs &&
        (y1 - y).abs >= (y1 - dst_y).abs
    else
      false
    end
  end
end

class SolutionTest < Minitest::Test
  POS = DATA.pos

  def setup
    DATA.pos = POS
  end

  def test_part1_debug
    lines = read_multi_line(DATA, ",")
    assert_equal 6, Solution.new(lines[0, 2]).part1
    assert_equal 159, Solution.new(lines[3, 2]).part1
    assert_equal 135, Solution.new(lines[6, 2]).part1
  end

  def test_part1_real
    file = File.new("input")
    lines = read_multi_line(file, ",")
    file.close

    puts "Part1 Solution: #{Solution.new(lines).part1}"
  end

  def test_part2_debug
    lines = read_multi_line(DATA, ",")
    assert_equal 30, Solution.new(lines[0, 2]).part2
    assert_equal 610, Solution.new(lines[3, 2]).part2
    assert_equal 410, Solution.new(lines[6, 2]).part2
  end

  def test_part2_real
    file = File.new("input")
    lines = read_multi_line(file, ",")
    file.close

    puts "Part2 Solution: #{Solution.new(lines).part2}"
  end

  private

  def read_multi_line(file, sep = nil)
    file.map do |line|
      line.chomp!
      if sep
        line.split(sep)
      else
        line
      end
    end
  end
end

__END__
R8,U5,L5,D3
U7,R6,D4,L4

R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83

R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
