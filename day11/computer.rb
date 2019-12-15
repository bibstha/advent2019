class Memory
  def initialize(software)
    @memory = Hash.new(0)
    software.each_with_index do |val, i|
      @memory[i] = val
    end
    # @software = software.dup
  end

  def [](x, size=nil)
    raise ArgumentError, "position cannot be negative" if x < 0
    if size.nil?
      @memory[x]
    else
      (0...size).map.with_index do |val, i|
        raise ArgumentError, "position cannot be negative" if i < 0
        @memory[x + i]
      end
    end
  end

  def []=(x, y)
    raise ArgumentError, "position cannot be negative" if x < 0
    @memory[x] = y
  end

  def to_a
    @memory.values
  end
end

class IntcodeComputer
  attr_accessor :input_iterator, :memory, :current_instruction_pos

  def initialize(software)
    @memory = Memory.new(software)
    @input = []
    @tokenizer = Tokenizer.new(@memory, @input.each)
  end

  def output_handler=(handler)
    @output_handler = handler
  end

  def append_input(val)
    @input << val
  end

  def run
    @tokenizer.intcode_iterator.each do |intcode|
      intcode.run
      if intcode.output
        raise "Output handler missing" if @output_handler.nil?
        @output_handler.call(intcode.output)
        # break
      end
      break if intcode.halt
    end
  end
end

IntcodePositionTracker = Struct.new(:position)

class Tokenizer
  MAX_ARG_SIZE = 3

  attr_reader :position_tracker

  def initialize(memory, input_iterator)
    @memory = memory
    @input_iterator = input_iterator
    @position_tracker = IntcodePositionTracker.new(0)
    @relative_base_tracker = IntcodePositionTracker.new(0)
  end

  def intcode_iterator
    @enum ||= Enumerator.new do |y|
      loop do
        current_pos = @position_tracker.position
        intcode_value = @memory[current_pos]
        args = @memory[current_pos + 1, MAX_ARG_SIZE]
        y << Intcode.new(
          intcode_value,
          args,
          @memory,
          @input_iterator,
          @position_tracker,
          @relative_base_tracker,
        )
      end
    end
  end
end

class Intcode
  attr_reader :output, :jump_to, :halt

  def initialize(intcode_value, args, memory, input_iterator, position_tracker, relative_base_tracker)
    @intcode_value = sprintf("%05d", intcode_value)
    @args = args
    @memory = memory
    @input_iterator = input_iterator
    @position_tracker = position_tracker
    @relative_base_tracker = relative_base_tracker
  end

  def run
    @output = nil
    @jump_to = nil
    @halt = false

    if opcode == "01"
      @int_size = 4
      dst = param(3, mode: :write)
      @memory[dst] = param(1) + param(2)
    elsif opcode == "02"
      @int_size = 4
      dst = param(3, mode: :write)
      @memory[dst] = param(1) * param(2)
    elsif opcode == "03"
      @int_size = 2
      begin
        input = @input_iterator.next
      rescue StopIteration
        raise "Input Not Found"
      end
      dst = param(1, mode: :write)
      @memory[dst] = input
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
      dst = param(3, mode: :write)
      @memory[dst] = param(1) < param(2) ? 1 : 0
    elsif opcode == "08"
      @int_size = 4
      dst = param(3, mode: :write)
      @memory[dst] = param(1) == param(2) ? 1 : 0
    elsif opcode == "09"
      @int_size = 2
      @relative_base_tracker.position += param(1)
    elsif opcode == "99"
      @int_size = 1
      @halt = true
    else
      raise "Unknown opcode #{opcode}"
    end

    move_position
  end

  def opcode
    @intcode_value[-2..-1]
  end

  # param(1) gives 1st param
  def param(num, mode: :default)
    intcode_pos = -2 - num
    param = nil
    if mode == :default
      mode = case @intcode_value[intcode_pos]
      when "0"
        "positional"
      when "1"
        "immediate"
      when "2"
        "relative"
      else
        raise "Unknown intcode value #{@intcode_value[intcode_pos]}"
      end

      arg = @args[num - 1]
      param = arg if mode == "immediate"
      param = @memory[arg] if mode == "positional"
      param = @memory[@relative_base_tracker.position + arg] if mode == "relative"
      param
    elsif mode == :write
      mode = case @intcode_value[intcode_pos]
      when "0", "1"
        "positional"
      when "2"
        "relative"
      else
        raise "Unknown intcode value #{@intcode_value[intcode_pos]}"
      end

      arg = @args[num - 1]
      param = arg if mode == "positional"
      param = @relative_base_tracker.position + arg if mode == "relative"
    else
      raise "Unknown mode found #{mode}"
    end
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
