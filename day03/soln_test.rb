require 'minitest/autorun'

class Solution
  def initialize(file)
    @f = file
  end

  def read_multi_line(sep = nil)
    @f.map do |line|
      line.chomp!
      if sep
        line.split(sep)
      else
        line
      end
    end
  end

  def one_line(sep)
    read_multi_line(sep).flatten
  end

  def main()
    # p read_multi_line(",")
    # p one_line(",")
    line1, line2 = read_multi_line(",")
    @line1 = line1
    @line2 = line2
    p line1
    p line2

    @points = Hash.new { |h, k| h[k] = Hash.new(nil) }
    traverse(line1, "first")
    traverse(line2, "second")
    p1_shortest_distance
    p2_number_of_steps
  end

  def traverse(line, type)
    x, y = [0, 0]
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
      @points[x][y] = "boom"
    else
      @points[x][y] = type
    end
  end

  def p1_shortest_distance
    shortest_distance = 10000000
    @points.each do |i, hash|
      hash.each do |j, type|
        if type == "boom"
          dist = i.abs + j.abs
          if shortest_distance > dist
            shortest_distance = dist
          end
        end
      end
    end
    puts "p1: Shortest distance: #{shortest_distance}"
  end

  def p2_number_of_steps
    shortest_steps = 10000000
    @points.each do |i, hash|
      hash.each do |j, type|
        if type == "boom"
          total = traverse2(@line1, i, j) + traverse2(@line2, i, j)

          if shortest_steps > total
            shortest_steps = total
          end
        end
      end
    end
    puts "p2: Shortest steps: #{shortest_steps}"
  end

  def traverse2(line, dst_x, dst_y)
    x, y = [0, 0]
    moved = 0
    found = false
    line.each do |direction|
      distance = direction[1..-1].to_i
      if direction[0] == "R"
        (1..distance).each do |i|
          x = x + 1
          moved += 1
          if x == dst_x && y == dst_y
            found = true
            break
          end
        end
      elsif direction[0] == "L"
        (1..distance).each do |i|
          x = x - 1
          moved += 1
          if x == dst_x && y == dst_y
            found = true
            break
          end
        end
      elsif direction[0] == "U"
        (1..distance).each do |i|
          y = y + 1
          moved += 1
          if x == dst_x && y == dst_y
            found = true
            break
          end
        end
      elsif direction[0] == "D"
        (1..distance).each do |i|
          y = y - 1
          moved += 1
          if x == dst_x && y == dst_y
            found = true
            break
          end
        end
      end
      break if found
    end
    moved
  end
end

class SolutionTest < Minitest::Test
  def setup
    @debug = false
  end

  def test_part1
    if @debug
      Solution.new(DATA).main
    else
      Solution.new(File.new("input")).main
    end
  end
end

__END__
R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83
R8,U5,L5,D3
U7,R6,D4,L4
