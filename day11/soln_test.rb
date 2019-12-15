require 'minitest/autorun'
require_relative 'computer'

class Panels
  def initialize
    @panels = Hash.new(0) # by default all panels are black
  end

  def paint(x, y, value)
    @panels[[x, y]] = value # value = 0 black, 1 white
  end

  def color_at(x, y)
    @panels[[x, y]]
  end

  def count_painted_panels
    @panels.size
  end

  def to_s
    keys = @panels.keys
    minx, maxx = keys.minmax_by { |xy| xy[0] }.map! { |xy| xy[0] }
    miny, maxy = keys.minmax_by { |xy| xy[1] }.map! { |xy| xy[1] }

    str = maxy.downto(miny).map do |y|
      line = (minx..maxx).map do |x|
        @panels[[x, y]] == 0 ? " " : "#"
      end
      line.join
    end
    str.join("\n")
  end
end

class Robot
  DIRN = %w(U R D L)
  DX = { "L" => -1, "U" => 0, "R" => 1, "D" => 0 }
  DY = { "L" => 0, "U" => 1, "R" => 0, "D" => -1 }

  attr_reader :panels

  def initialize(computer)
    @panels = Panels.new
    @pos = [0, 0]
    @dir = "U"
    @computer = computer
    @panels.paint(0, 0, 1)
  end

  def current_panel_color
    @panels.color_at(*@pos)
  end

  def paint
    @computer.append_input(current_panel_color)
    outputs = []
    @computer.output_handler = Proc.new do |x|
      outputs << x
      if outputs.size == 2
        @panels.paint(@pos[0], @pos[1], outputs[0])
        if outputs[1] == 0
          turn_left_and_move
        elsif outputs[1] == 1
          turn_right_and_move
        else
          raise "Turn should be 0 or 1, found #{outputs[1]}"
        end
        outputs.clear
        @computer.append_input(current_panel_color)
      end
    end

    @computer.run
  end

  def turn_left_and_move
    new_dir_i = (DIRN.find_index(@dir) - 1) % 4
    new_dir = DIRN[new_dir_i]
    move(new_dir)
  end

  def turn_right_and_move
    new_dir_i = (DIRN.find_index(@dir) + 1) % 4
    new_dir = DIRN[new_dir_i]
    move(new_dir)
  end

  def move(new_dir)
    x1 = @pos[0] + DX[new_dir]
    y1 = @pos[1] + DY[new_dir]
    @dir = new_dir
    @pos = [x1, y1]
  end
end

class Day11Test < Minitest::Test
  def test_eg1
    software = File.read("input").chomp.split(",").map(&:to_i)
    computer = IntcodeComputer.new(software)
    robot = Robot.new(computer)
    robot.paint

    p "Total painted panels: #{robot.panels.count_painted_panels}"
    puts robot.panels.to_s
  end
end
