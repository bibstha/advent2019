class Moon
  attr_reader :vel, :base
  def initialize(x, y, z)
    @base = [x, y, z]
    @orig = @base.dup
    @vel = [0, 0, 0]
  end

  def status
    puts "<x=#{x}, y=#{y}, z=#{z}>, vel=<x=#{vel_x}, y=#{vel_y}, z=#{vel_z}>, energy=#{energy}"
  end

  def energy
    (x.abs + y.abs + z.abs) * (vel_x.abs + vel_y.abs + vel_z.abs)
  end

  def orig_pos_for(pos)
    vel[pos] == 0 && base[pos] == @orig[pos]
  end

  def x; @base[0]; end
  def y; @base[1]; end
  def z; @base[2]; end
  def vel_x; @vel[0]; end
  def vel_y; @vel[1]; end
  def vel_z; @vel[2]; end
end

class Jupiter
  attr_reader :time

  def initialize(moons)
    @moons = moons
    @time = 0
  end

  def tick
    @time += 1
    tick_pos(0)
    tick_pos(1)
    tick_pos(2)
  end

  def status
    @moons.each do |moon|
      moon.status
    end
  end

  def total_energy
    @moons.sum(&:energy)
  end

  def tick_pos(pos)
    @moons.combination(2).each do |moon1, moon2|
      moon1_inc = 0

      if moon1.base[pos] < moon2.base[pos]
        moon1_inc = 1
      elsif moon1.base[pos] > moon2.base[pos]
        moon1_inc = -1
      end

      moon1.vel[pos] += moon1_inc
      moon2.vel[pos] -= moon1_inc
    end

    @moons.each do |moon|
      moon.base[pos] += moon.vel[pos]
    end
  end

  def orig_pos(pos)
    @moons.all? { |moon| moon.orig_pos_for(pos) }
  end
end

require 'minitest/autorun'

class AdventTest < Minitest::Test
  def test_example1
    lines = File.readlines("input_eg1").map(&:chomp!)
    line_matcher = /<x=(-?[0-9]+), y=(-?[0-9]+), z=(-?[0-9]+)>/
    moons = []
    lines.each do |line|
      base_xyz = line_matcher.match(line)[1..3].map(&:to_i)
      moons << Moon.new(*base_xyz)
    end

    planet = Jupiter.new(moons)
    10.times { planet.tick }
    planet.status
    # puts "Total energy = #{planet.total_energy}"
    assert_equal 179, planet.total_energy
  end

  def test_example2
    lines = File.readlines("input_eg2").map(&:chomp!)
    line_matcher = /<x=(-?[0-9]+), y=(-?[0-9]+), z=(-?[0-9]+)>/
    moons = []
    lines.each do |line|
      base_xyz = line_matcher.match(line)[1..3].map(&:to_i)
      moons << Moon.new(*base_xyz)
    end

    planet = Jupiter.new(moons)
    100.times { planet.tick }
    planet.status
    # puts "Total energy = #{planet.total_energy}"
    assert_equal 1940, planet.total_energy
  end

  def test_part1
    lines = File.readlines("input").map(&:chomp!)
    line_matcher = /<x=(-?[0-9]+), y=(-?[0-9]+), z=(-?[0-9]+)>/
    moons = []
    lines.each do |line|
      base_xyz = line_matcher.match(line)[1..3].map(&:to_i)
      moons << Moon.new(*base_xyz)
    end

    planet = Jupiter.new(moons)
    1000.times { planet.tick }
    planet.status
    # puts "Total energy = #{planet.total_energy}"
    assert_equal 8287, planet.total_energy
  end

  def test_example1_repeat
    lines = File.readlines("input_eg1").map(&:chomp!)
    line_matcher = /<x=(-?[0-9]+), y=(-?[0-9]+), z=(-?[0-9]+)>/
    moons = []
    lines.each do |line|
      base_xyz = line_matcher.match(line)[1..3].map(&:to_i)
      moons << Moon.new(*base_xyz)
    end

    planet = Jupiter.new(moons)

    reps = (0..2).map do |pos|
      time = 0
      loop do
        time += 1
        planet.tick_pos(pos)
        break if planet.orig_pos(pos)
      end

      time
    end
    puts "The planets get back to original position in #{reps.reduce(:lcm)} times"
  end

  def test_example2_repeat
    lines = File.readlines("input_eg2").map(&:chomp!)
    line_matcher = /<x=(-?[0-9]+), y=(-?[0-9]+), z=(-?[0-9]+)>/
    moons = []
    lines.each do |line|
      base_xyz = line_matcher.match(line)[1..3].map(&:to_i)
      moons << Moon.new(*base_xyz)
    end

    planet = Jupiter.new(moons)

    reps = (0..2).map do |pos|
      time = 0
      loop do
        time += 1
        planet.tick_pos(pos)
        break if planet.orig_pos(pos)
      end

      time
    end
    puts "The planets get back to original position in #{reps.reduce(:lcm)} times"
  end

  def test_part2
    lines = File.readlines("input").map(&:chomp!)
    line_matcher = /<x=(-?[0-9]+), y=(-?[0-9]+), z=(-?[0-9]+)>/
    moons = []
    lines.each do |line|
      base_xyz = line_matcher.match(line)[1..3].map(&:to_i)
      moons << Moon.new(*base_xyz)
    end

    planet = Jupiter.new(moons)

    reps = (0..2).map do |pos|
      time = 0
      loop do
        time += 1
        planet.tick_pos(pos)
        break if planet.orig_pos(pos)
      end

      time
    end
    puts "The planets get back to original position in #{reps.reduce(:lcm)} times"
  end
end
