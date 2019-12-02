input = File.read('input')

# input = "1,0,0,0,99"

input = input.split(",").map(&:to_i)

def compute(i, input)
  raise "End" if i >= input.size

  command = input[i]
  if [1, 2].include?(command)
    arg1 = input[input[i+1]]
    arg2 = input[input[i+2]]
    arg3 = input[i+3]

    if command == 1
      input[arg3] = arg1 + arg2
    else
      input[arg3] = arg1 * arg2
    end
  else
    raise "End"
  end
end

# test = [
#   1,1,1,4,99,5,6,0,99
# ]

def run(noun, verb, input)
  input[1] = noun
  input[2] = verb

  i = 0
  while i <= input.size do
    begin
      compute(i, input)
    rescue
    end
    i += 4
  end

  input[0]
end

# part 1
puts run(12, 2, input.dup)

# part 2
(0..99).each do |noun|
  (0..99).each do |verb|
    val = run(noun, verb, input.dup)
    if val == 19690720
      puts 100 * noun + verb
    end
  end
end
