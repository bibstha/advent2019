a1 = 254032
a2 = 789860

ans1 = 0
ans2 = 0

total = (a1..a2).each do |x|
  chars = x.to_s.chars
  sorted = chars.sort
  next if chars != sorted

  slices = chars.slice_when { |a, b| a!= b }.to_a

  ans1 += 1 if slices.count < 6
  ans2 += 1 if slices.any? { |x| x.size == 2 }
end

puts ans1
puts ans2
