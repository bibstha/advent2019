require 'minitest/autorun'
require_relative 'computer'

class MyTest < Minitest::Test
  def setup
    @input_iterator = [].each
    @memory = [5,6,7,8]
    @position_tracker = IntcodePositionTracker.new(0)
    @relative_base_tracker = IntcodePositionTracker.new(0)
  end

  def test_intcode
    intcode = Intcode.new(1001, [1, 1, 1], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    assert_equal "01", intcode.opcode
    assert_equal 6, intcode.param(1)
    assert_equal 1, intcode.param(2)
    assert_equal 6, intcode.param(3)
  end

  def test_intcode_opcode_01
    intcode = Intcode.new(1001, [1, 1, 1], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,7,7,8], @memory
  end

  def test_intcode_opcode_02
    intcode = Intcode.new(1002, [1, 1, 3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,6], @memory
  end

  def test_intcode_opcode_03
    input_iterator = [42].each
    intcode = Intcode.new(1003, [2], @memory, input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,42,8], @memory
  end

  def test_intcode_opcode_04
    intcode = Intcode.new(1004, [2], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,8], @memory
    assert_equal 7, intcode.output
  end

  def test_intcode_opcode_05
    intcode = Intcode.new(1105, [1, 3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,8], @memory
    assert_equal 3, intcode.jump_to

    intcode = Intcode.new(1105, [0, 3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,8], @memory
    assert_nil intcode.jump_to
  end

  def test_intcode_opcode_06
    intcode = Intcode.new(1106, [0, 3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,8], @memory
    assert_equal 3, intcode.jump_to

    intcode = Intcode.new(1106, [1, 3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,8], @memory
    assert_nil intcode.jump_to
  end

  def test_intcode_opcode_07
    intcode = Intcode.new(1107, [0, 1, 3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,1], @memory
    assert_nil intcode.jump_to

    intcode = Intcode.new(1107, [1, 1, 3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,0], @memory
    assert_nil intcode.jump_to

    intcode = Intcode.new(1107, [2, 1, 3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,0], @memory
    assert_nil intcode.jump_to
  end

  def test_intcode_opcode_08
    intcode = Intcode.new(1108, [0, 0, 3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,1], @memory
    assert_nil intcode.jump_to

    intcode = Intcode.new(1108, [1, 0, 3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,0], @memory
    assert_nil intcode.jump_to

    intcode = Intcode.new(1108, [0, 1, 3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,0], @memory
    assert_nil intcode.jump_to
  end

  def test_intcode_mode_relative
    @relative_base_tracker.position = 3
    # print at location 3 - 3 = 0 (number 5)
    intcode = Intcode.new(204, [-3], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,8], @memory
    assert_nil intcode.jump_to
    assert_equal 3, @relative_base_tracker.position
    assert_equal 5, intcode.output
  end

  def test_intcode_opcode_09
    intcode = Intcode.new(109, [9], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,8], @memory
    assert_nil intcode.jump_to
    assert_equal 9, @relative_base_tracker.position

    intcode = Intcode.new(109, [19], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    intcode.run
    assert_equal [5,6,7,8], @memory
    assert_nil intcode.jump_to
    assert_equal 9 + 19, @relative_base_tracker.position
  end

  def test_param_mode_write_vs_default
    intcode = Intcode.new(109, [1,2,3,4], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    assert_equal [5,6,7,8], @memory
    assert_equal 1, intcode.param(1, mode: :write)
    assert_equal 2, intcode.param(2, mode: :write)

    assert_equal 1, intcode.param(1)
    assert_equal 7, intcode.param(2)

    @relative_base_tracker.position = 2
    intcode = Intcode.new(203, [1], @memory, @input_iterator, @position_tracker, @relative_base_tracker)
    assert_equal [5,6,7,8], @memory
    assert_equal 3, intcode.param(1, mode: :write)
    assert_equal 8, intcode.param(1)
  end
end

class TokenizerTest < Minitest::Test
  def test_initial_token
    memory = [1108, 0, 0, 3, 99]
    input_iterator = [].each

    tokenizer = Tokenizer.new(memory)
    tokenizer.input_iterator = input_iterator

    intcode_iterator = tokenizer.intcode_iterator

    # does not change position unless intcode is run
    intcode_iterator.next
    assert_equal 0, tokenizer.position_tracker.position

    # returns the same intcode since last intcode wasn't run
    intcode2 = intcode_iterator.next
    assert_equal 0, tokenizer.position_tracker.position

    intcode2.run
    assert_equal 4, tokenizer.position_tracker.position
  end
end

class IntcodeComputerTest < Minitest::Test
  def test_simple
    software = [1108, 0, 0, 3, 99]
    computer = IntcodeComputer.new(software)
    computer.run
  end

  def test_with_empty_input
    software = [1103, 1, 0, 3, 99]
    computer = IntcodeComputer.new(software)
    assert_raises(RuntimeError) do
      computer.run
    end
  end

  def test_with_valid_input
    software = [1103, 1, 99]
    computer = IntcodeComputer.new(software)

    computer.append_input(542)
    computer.run
    assert_equal [1103, 542, 99], computer.memory.to_a
  end

  def test_output
    outputs = []
    output_handler = Proc.new { |x| outputs << x }

    software = [4, 2, 99]
    computer = IntcodeComputer.new(software)
    computer.output_handler = output_handler
    computer.run
    assert_equal software, computer.memory.to_a
    assert_equal [99], outputs
  end

  def test_input_and_output
    outputs = []
    output_handler = Proc.new { |x| outputs << x }

    software = [4, 8, 4, 0, 3, 0, 4, 0, 99]
    computer = IntcodeComputer.new(software)
    computer.output_handler = output_handler
    computer.append_input(523)

    computer.run
    assert_equal [99, 4, 523], outputs
  end
end

class MemoryTest < Minitest::Test
  def test_read_access
    mem = Memory.new([5,6,7])
    assert_equal 6, mem[1]

    assert_equal [6,7], mem[1, 2]

    assert_equal 0, mem[1000]
  end

  def test_write
    mem = Memory.new([5,6,7])
    mem[2000] = 100

    assert_equal 100, mem[2000]
  end
end
