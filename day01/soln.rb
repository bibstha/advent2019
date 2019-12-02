debug = false
f = File.new('input')

def weight(mass)
  w = (mass / 3) - 2 
  return 0 if w <= 0

  w + weight(w)
end

# f = %w(12 14 1969 100756)
# debug = true

sum = 0
f.each do |line|
  w = weight(line.to_i)
  puts "w for #{line} is #{w}" if debug
  sum += w
end

puts "Total sum: #{sum}"
