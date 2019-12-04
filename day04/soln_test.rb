a1 = 254032
a2 = 789860

def qualify?(x)
  chars = x.to_s.chars
  sorted = chars.sort
  chars == sorted && (
    # part 1
    chars.slice_when { |a, b| a!= b }.count < 6

    # part 2
    # chars.slice_when { |a, b| a != b }.any? { |x| x.size == 2 }
  )
end

total = (a1..a2).count do |x|
  qualify?(x)
end

puts total
