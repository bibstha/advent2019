require_relative 'computer'
require 'io/console'

Node = Struct.new(:dir, :will_expand, :level)

class Robot
  def initialize(input)
    @dirs = %i(e s w n)
    @opposites = { n: :s, s: :n, e: :w, w: :e }
    @input = { n: 1, s: 2, w: 3, e: 4 }
    @computer = IntcodeComputer.load_from_disk(input)

    @last_output = nil
    @computer.output_handler = Proc.new do |output|
      @last_output = output
    end
    @computer.input_iterator = self
    # starting direction = n
    @direction = :n

    @search_oxygen = true
    @stack = []
  end

  def run
    @computer.run
  end

  # called by computer
  def next
    process_stack

    dir = @stack[-1].dir
    @input[dir]
  end

  def process_stack
    if @search_oxygen
      if @last_output.nil?
        @stack.concat(new_nodes_from(nil))
      elsif @last_output == 0
        @stack.pop
      elsif @last_output == 1
        node = @stack.pop
        @stack.concat(new_nodes_from(node))
      elsif @last_output == 2
        @search_oxygen = false
        node = @stack.last
        puts "Output 2 found at Node: #{node}, distance: #{node.level}"
        @stack.clear
        @stack.concat(new_nodes_from(nil))
        @last_output = nil
      end
    else
      @max_dist ||= 0

      if @last_output == 0 || @last_output == 2
        @stack.pop
      elsif @last_output == 1
        node = @stack.pop
        @stack.concat(new_nodes_from(node))
        if node.level > @max_dist
          @max_dist = node.level
        end
      else
        raise "WRONG INPUT"
      end

      if @stack.empty?
        puts "Max dist #{@max_dist}"
        exit
      end
    end
  end

  def new_nodes_from(node)
    if node.nil?
      @dirs.map { |d| Node.new(d, true, 1) }
    elsif node.will_expand == false
      []
    else
      opposite_dir = @opposites.fetch(node.dir)
      dirs = @dirs
        .select { |dir| dir != opposite_dir }
        .map { |d| Node.new(d, true, node.level + 1) }
      dirs.unshift(Node.new(opposite_dir, false, node.level - 1))
      dirs
    end
  end
end

require 'minitest/autorun'

class AdventTest < Minitest::Test
  def test_part1
    r = Robot.new("input.txt")
    r.run
  end
end
