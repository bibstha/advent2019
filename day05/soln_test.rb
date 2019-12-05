HaltError = Class.new(StandardError)

input = File.read('input')
input = input.split(",").map(&:to_i)

def compute(i, input, opcode)
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
    puts "OUTPUT: #{param1}"
    i += 2
  elsif command == "3"
    param1 = input[i + 1]
    a = gets
    a.chomp!
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

def run(input)
  i = 0

  while i <= input.size do
    opcode = input[i]
    opcode = sprintf("%05d", opcode) 

    begin
      i = compute(i, input, opcode)
    rescue HaltError => e
      break
    end
  end
end

run(input.dup)

