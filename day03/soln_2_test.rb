# ruby version of elegant python solution from
# https://www.reddit.com/r/adventofcode/comments/e5bz2w/2019_day_3_solutions/f9iz68s/
DX = { L: -1, R: 1, U: 0, D: 0 }
DY = { L: 0, R: 0, U: 1, D: -1 }

def points(a)
  points = {}
  x, y = 0, 0
  length = 0

  a.each do |direction|
    d = direction[0].to_sym
    n = direction[1..-1].to_i

    n.times do |i|
      x += DX[d]
      y += DY[d]
      length += 1

      points[[x, y]] ||= length
    end
  end

  points
end

line1, line2 = File.readlines("input")
  .map!(&:chomp)
  .map! { |x| x.split(",") }

pA = points(line1)
pB = points(line2)

both = pA.keys & pB.keys

part1 = both.map { |i, j| i.abs + j.abs }.min
part2 = both.map { |i, j| pA[[i, j]] + pB[[i, j]] }.min

puts "Part1: #{part1}"
puts "Part2: #{part2}"
