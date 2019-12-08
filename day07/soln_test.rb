HaltError = Class.new(StandardError)

input = File.read('input')
# input = DATA.readlines[0]
input = input.split(",").map(&:to_i)

$last_output = nil

def compute(i, input, opcode, params)
  # p params

  raise "End" if i >= input.size

  command = opcode[4]
  if command == "1" || command == "2"
    param1 = input[i + 1]
    param2 = input[i + 2]
    param3 = input[i + 3]

    param1 = input[param1] if opcode[2] == "0"
    param2 = input[param2] if opcode[1] == "0"

    if command == "1"
      input[param3] = param1 + param2
    else
      input[param3] = param1 * param2
    end
    i += 4
  elsif command == "4"
    param1 = input[i + 1]
    param1 = input[param1] if opcode[2] == "0"

    $last_output = param1
    # puts "OUTPUT: #{param1}"

    i += 2
  elsif command == "3"
    param1 = input[i + 1]
    # puts "Input?"

    # get input
    a = params.delete_at(0)
    # p a
    # a = gets
    #
    # a.chomp!
    input[param1] = a.to_i
    i += 2
  elsif command == "5"
    param1 = input[i + 1]
    param2 = input[i + 2]
    param1 = input[param1] if opcode[2] == "0"
    param2 = input[param2] if opcode[1] == "0"

    if param1 != 0
      i = param2
    else
      i += 3
    end
  elsif command == "6"
    param1 = input[i + 1]
    param2 = input[i + 2]
    param1 = input[param1] if opcode[2] == "0"
    param2 = input[param2] if opcode[1] == "0"

    if param1 == 0
      i = param2
    else
      i += 3
    end
  elsif command == "7"
    param1 = input[i + 1]
    param2 = input[i + 2]
    param3 = input[i + 3]

    param1 = input[param1] if opcode[2] == "0"
    param2 = input[param2] if opcode[1] == "0"
    if param1 < param2
      input[param3] = 1
    else
      input[param3] = 0
    end
    i += 4
  elsif command == "8"
    param1 = input[i + 1]
    param2 = input[i + 2]
    param3 = input[i + 3]

    param1 = input[param1] if opcode[2] == "0"
    param2 = input[param2] if opcode[1] == "0"
    if param1 == param2
      input[param3] = 1
    else
      input[param3] = 0
    end
    i += 4
  else
    raise HaltError, "Found opcode #{opcode}"
  end
  i
end

def run(input, a, b)
  params = [a, b]
  i = 0

  while i <= input.size do
    opcode = input[i]
    opcode = sprintf("%05d", opcode)

    begin
      i = compute(i, input, opcode, params)
    rescue HaltError => e
      break
    end
  end
end

def find(input, seq)
  last_output = 0
  seq.each do |i|
    run(input.dup, i, last_output)
    last_output = $last_output
  end

  puts "#{seq} - Output = #{last_output}" if last_output == 17178942
  last_output
end

# a = find(input, [1,1,1,1,1])

a = (0..99999).map do |i|
  next 0 unless i.to_s =~ /[5-9]/

  i = sprintf("%05d", i).chars.map!(&:to_i)
  next 0 if i.uniq.size < i.size

  seq = i

  find(input, seq)
end.max

p "max = #{a}"

__END__
3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0
