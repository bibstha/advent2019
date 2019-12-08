require 'minitest/autorun'

class Amplifier
  def initialize(phase)
    @phase = phase
  end

  def output_receiver=(amplifier)
    @output_receiver = amplifier
  end

  def enqueue_signal(signal)
  end
end

class IntcodeComputer
  attr_accessor :input_iterator, :memory, :current_instruction_pos

  def initialize(software)
    @memory = software.dup
    # @tokenizer = Tokenizer.new(@memory, )
    @current_instruction_pos = 0
  end

  def output_handler=(handler)
  end

  def run
    @tokenizer.intcode_iterator.each do |intcode|
      intcode.run
    end
  end
end

IntcodePositionTracker = Struct.new(:position)

class Tokenizer
  MAX_ARG_SIZE = 3

  def initialize(memory, input_iterator, computer)
    @memory = memory
    @input_iterator = input_iterator
    @position_tracker = IntcodePositionTracker.new(0)
  end

  def intcode_iterator
    current_pos = @position_tracker.position
    intcode_value = @memory[current_pos]
    args = @memory[current_pos + 1, MAX_ARG_SIZE]
    Intcode.new(intcode_value, args, @memory, @input_iterator, @position_tracker)
  end
end

class Intcode
  attr_reader :output, :jump_by, :jump_to, :halt

  def initialize(intcode_value, args, memory, input_iterator, position_tracker)
    @intcode_value = sprintf("%05d", intcode_value)
    @args = args
    @memory = memory
    @input_iterator = input_iterator
    @position_tracker = position_tracker
  end

  def run
    @output = nil
    @jump_to = nil
    @halt = false

    if opcode == "01"
      @int_size = 4
      @memory[@args[2]] = param(1) + param(2)
    elsif opcode == "02"
      @int_size = 4
      @memory[@args[2]] = param(1) * param(2)
    elsif opcode == "03"
      @int_size = 2
      input = @input_iterator.next
      @memory[@args[0]] = input
    elsif opcode == "04"
      @int_size = 2
      @output = param(1)
    elsif opcode == "05"
      @int_size = 3
      @jump_to = param(2) if param(1) != 0
    elsif opcode == "06"
      @int_size = 3
      @jump_to = param(2) if param(1) == 0
    elsif opcode == "07"
      @int_size = 4
      @memory[@args[2]] = param(1) < param(2) ? 1 : 0
    elsif opcode == "08"
      @int_size = 4
      @memory[@args[2]] = param(1) == param(2) ? 1 : 0
    elsif opcode == "99"
      @int_size = 1
      @halt = true
    end

    move_position
  end

  def opcode
    @intcode_value[-2..-1]
  end

  # param(1) gives 1st param
  def param(num)
    intcode_pos = -2 - num
    mode = @intcode_value[intcode_pos] == "0" ? "positional" : "immediate"
    param = @args[num - 1] if mode == "immediate"
    param = @memory[@args[num - 1]] if mode == "positional"
    param
  end

  def move_position
    if @jump_to
      @position_tracker.position = @jump_to
    else
      @position_tracker.position += @int_size
    end
  end
end


class MyTest < Minitest::Test
  def test_intcode
    input_iterator = [].each
    memory = [5,6,7,8]
    intcode = Intcode.new(1001, [1, 1, 1], memory, input_iterator)
    assert_equal "01", intcode.opcode
    assert_equal 6, intcode.param(1)
    assert_equal 1, intcode.param(2)
    assert_equal 6, intcode.param(3)
  end

  def test_intcode_opcode_01
    input_iterator = [].each
    memory = [5,6,7,8]
    intcode = Intcode.new(1001, [1, 1, 1], memory, input_iterator)
    assert_equal 6, memory[1]
    intcode.run
    assert_equal 7, memory[1]
  end

  def test_intcode_opcode_02
    input_iterator = [].each
    memory = [5,6,7,8]
    intcode = Intcode.new(1002, [1, 1, 3], memory, input_iterator)
    assert_equal 8, memory[3]
    intcode.run
    assert_equal 6, memory[3]
  end

  def test_intcode_opcode_03
    input_iterator = [42].each

    memory = [5,6,7,8]
    intcode = Intcode.new(1003, [2], memory, input_iterator)
    intcode.run
    assert_equal [5,6,42,8], memory
  end

  def test_intcode_opcode_04
    input_iterator = [].each
    memory = [5,6,7,8]
    intcode = Intcode.new(1004, [2], memory, input_iterator)
    intcode.run
    assert_equal [5,6,7,8], memory
    assert_equal 7, intcode.output
  end

  def test_intcode_opcode_05
    input_iterator = [].each
    memory = [5,6,7,8]
    intcode = Intcode.new(1105, [1, 3], memory, input_iterator)
    intcode.run
    assert_equal [5,6,7,8], memory
    assert_equal 3, intcode.jump_to

    intcode = Intcode.new(1105, [0, 3], memory, input_iterator)
    intcode.run
    assert_equal [5,6,7,8], memory
    assert_nil intcode.jump_to
  end

  def test_intcode_opcode_06
    input_iterator = [].each
    memory = [5,6,7,8]
    intcode = Intcode.new(1106, [0, 3], memory, input_iterator)
    intcode.run
    assert_equal [5,6,7,8], memory
    assert_equal 3, intcode.jump_to

    intcode = Intcode.new(1106, [1, 3], memory, input_iterator)
    intcode.run
    assert_equal [5,6,7,8], memory
    assert_nil intcode.jump_to
  end

  def test_intcode_opcode_07
    input_iterator = [].each
    memory = [5,6,7,8]
    intcode = Intcode.new(1107, [0, 1, 3], memory, input_iterator)
    intcode.run
    assert_equal [5,6,7,1], memory
    assert_nil intcode.jump_to

    intcode = Intcode.new(1107, [1, 1, 3], memory, input_iterator)
    intcode.run
    assert_equal [5,6,7,0], memory
    assert_nil intcode.jump_to

    intcode = Intcode.new(1107, [2, 1, 3], memory, input_iterator)
    intcode.run
    assert_equal [5,6,7,0], memory
    assert_nil intcode.jump_to
  end

  def test_intcode_opcode_08
    input_iterator = [].each
    memory = [5,6,7,8]
    intcode = Intcode.new(1108, [0, 0, 3], memory, input_iterator)
    intcode.run
    assert_equal [5,6,7,1], memory
    assert_nil intcode.jump_to

    intcode = Intcode.new(1108, [1, 0, 3], memory, input_iterator)
    intcode.run
    assert_equal [5,6,7,0], memory
    assert_nil intcode.jump_to

    intcode = Intcode.new(1108, [0, 1, 3], memory, input_iterator)
    intcode.run
    assert_equal [5,6,7,0], memory
    assert_nil intcode.jump_to
  end
end

class TokenizerTest < Minitest::Test
  def test_initial_token
    memory = [1108, 0, 0, 3, 99]
    input_iterator = [].each
    position_tracker = IntcodePositionTracker.new(0)

    tokenizer = Tokenizer.new(memory, input_iterator, position_tracker)

    p intcode = tokenizer.intcode_iterator
    intcode.run

    p intcode = tokenizer.intcode_iterator
    intcode.run
  end
end

# HaltError = Class.new(StandardError)
#
# input = File.read('input')
# # input = DATA.readlines[0]
# input = input.split(",").map(&:to_i)
#
# $last_output = nil
#
# def compute(i, input, opcode, params)
#   # p params
#
#   raise "End" if i >= input.size
#
#   command = opcode[4]
#   if command == "1" || command == "2"
#     param1 = input[i + 1]
#     param2 = input[i + 2]
#     param3 = input[i + 3]
#
#     param1 = input[param1] if opcode[2] == "0"
#     param2 = input[param2] if opcode[1] == "0"
#
#     if command == "1"
#       input[param3] = param1 + param2
#     else
#       input[param3] = param1 * param2
#     end
#     i += 4
#   elsif command == "4"
#     param1 = input[i + 1]
#     param1 = input[param1] if opcode[2] == "0"
#
#     $last_output = param1
#     # puts "OUTPUT: #{param1}"
#
#     i += 2
#   elsif command == "3"
#     param1 = input[i + 1]
#     # puts "Input?"
#
#     # get input
#     a = params.delete_at(0)
#     # p a
#     # a = gets
#     #
#     # a.chomp!
#     input[param1] = a.to_i
#     i += 2
#   elsif command == "5"
#     param1 = input[i + 1]
#     param2 = input[i + 2]
#     param1 = input[param1] if opcode[2] == "0"
#     param2 = input[param2] if opcode[1] == "0"
#
#     if param1 != 0
#       i = param2
#     else
#       i += 3
#     end
#   elsif command == "6"
#     param1 = input[i + 1]
#     param2 = input[i + 2]
#     param1 = input[param1] if opcode[2] == "0"
#     param2 = input[param2] if opcode[1] == "0"
#
#     if param1 == 0
#       i = param2
#     else
#       i += 3
#     end
#   elsif command == "7"
#     param1 = input[i + 1]
#     param2 = input[i + 2]
#     param3 = input[i + 3]
#
#     param1 = input[param1] if opcode[2] == "0"
#     param2 = input[param2] if opcode[1] == "0"
#     if param1 < param2
#       input[param3] = 1
#     else
#       input[param3] = 0
#     end
#     i += 4
#   elsif command == "8"
#     param1 = input[i + 1]
#     param2 = input[i + 2]
#     param3 = input[i + 3]
#
#     param1 = input[param1] if opcode[2] == "0"
#     param2 = input[param2] if opcode[1] == "0"
#     if param1 == param2
#       input[param3] = 1
#     else
#       input[param3] = 0
#     end
#     i += 4
#   else
#     raise HaltError, "Found opcode #{opcode}"
#   end
#   i
# end
#
# def run(input, a, b)
#   params = [a, b]
#   i = 0
#
#   while i <= input.size do
#     opcode = input[i]
#     opcode = sprintf("%05d", opcode)
#
#     begin
#       i = compute(i, input, opcode, params)
#     rescue HaltError => e
#       break
#     end
#   end
# end
#
# def find(input, seq)
#   last_output = 0
#   seq.each do |i|
#     run(input.dup, i, last_output)
#     last_output = $last_output
#   end
#
#   puts "#{seq} - Output = #{last_output}" if last_output == 17178942
#   last_output
# end
#
# # a = find(input, [1,1,1,1,1])
#
# a = (0..99999).map do |i|
#   next 0 unless i.to_s =~ /[5-9]/
#
#   i = sprintf("%05d", i).chars.map!(&:to_i)
#   next 0 if i.uniq.size < i.size
#
#   seq = i
#
#   find(input, seq)
# end.max
#
# p "max = #{a}"
#
# __END__
# 3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0
