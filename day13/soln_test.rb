require_relative 'computer'
require 'io/console'

class Arcade
  attr_reader :tiles

  def initialize(computer)
    @tiles = {}
    @computer = computer
    @score = 0
    @input_iterator = InputIterator.new(default: 0)
    @ball_pos = nil
    @paddle_pos = nil
  end

  def load
    output_handler = ChunkOutputHandler.new(3) do |outputs|
      x, y, value = outputs
      if [x, y] == [-1, 0]
        @score = value
      else
        @tiles[[x, y]] = value
        case value
        when 3
          @paddle_pos = x
        when 4
          @ball_pos = x
          update_input
        end
      end
      puts to_s
    end
    @computer.output_handler = output_handler
    @computer.input_iterator = @input_iterator
    @computer.run
  end

  def update_input
    if @paddle_pos.nil?
      @input_iterator.right
    elsif @paddle_pos < @ball_pos
      @input_iterator.right
    elsif @paddle_pos > @ball_pos
      @input_iterator.left
    else
      @input_iterator.stay
    end
  end

  def to_s
    system("clear")
    keys = @tiles.keys
    minx, maxx = keys.minmax_by { |xy| xy[0] }.map! { |xy| xy[0] }
    miny, maxy = keys.minmax_by { |xy| xy[1] }.map! { |xy| xy[1] }

    str = (miny..maxy).map do |y|
      line = (minx..maxx).map do |x|
        val = @tiles[[x, y]]
        (val.nil? || val == 0) ? " " : val
      end
      line.join
    end

    "Paddle pos: #{@paddle_pos}\n" +
    "Ball pos: #{@ball_pos}\n" +
    "Score: #{@score}\n" + 
    str.join("\n")
  end
end

class InputIterator
  def initialize(default:)
    @value = default
  end

  def next
    @value
  end

  def left
    @value = -1
  end

  def right
    @value = 1
  end

  def stay
    @value = 0
  end
end

class ChunkOutputHandler
  def initialize(chunk_size, &block)
    @chunk_size = chunk_size
    @block = block
    @outputs = []
  end

  def call(output)
    @outputs << output
    if @outputs.size == @chunk_size
      @block.call(@outputs)
      @outputs.clear
    end
  end
end

require 'minitest/autorun'

class AdventTest < Minitest::Test
  def test_part1
    computer = IntcodeComputer.load_from_disk("input")
    arcade = Arcade.new(computer)
    arcade.load

    block_count = arcade.tiles.count { |_xy, id| id == 2 }
    assert_equal 239, block_count
    puts "Total block tiles: #{block_count}"

    puts arcade.to_s
  end

  def test_part2
    software = File.read("input").chomp.split(",").map(&:to_i)
    software[0] = 2
    computer = IntcodeComputer.new(software)
    arcade = Arcade.new(computer)
    arcade.load

    puts arcade.to_s
  end
end
