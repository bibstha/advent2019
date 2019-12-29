require 'minitest/autorun'
require 'set'

Item = Struct.new(:name, :quantity) do
  def to_s
    "#{quantity} #{name}"
  end
end

Reaction = Struct.new(:input_items, :output_item) do
  def to_s
    "#{input_items.join(", ")} => #{output_item}"
  end

  def replace(input_item, equivalent_items)
    input_items.delete(input_item)
    equivalent_items.each do |item|
      if (existing_item = input_items.find { |i| i.name == item.name })
        existing_item.quantity += item.quantity
      else
        input_items << item
      end
    end
  end
end

class Resolver
  attr_reader :waste

  def initialize(reactions, stock = [], graph_full, fuel_rxn, fuel_count: 1)
    @stock = stock.map(&:dup)
    @waste = []

    @reactions = reactions
    @graph_full = graph_full

    input_items = fuel_rxn.input_items.map(&:dup)
    input_items.each do |item|
      item.quantity *= fuel_count
    end

    output_item = fuel_rxn.output_item.dup
    output_item.quantity *= fuel_count

    @resolved_rxn = Reaction.new(input_items, output_item)
  end

  def ore_count
    @resolved_rxn.input_items.first.quantity
  end

  def resolve
    loop do
      consume_from_stock
      # puts @resolved_rxn
      # puts @stock.map(&:to_s).join(", ")
      items = resolve_item?
      break if items.empty?

      items.each do |item|
        replacement_items, waste_qty = requirement_for(item)
        @resolved_rxn.replace(item, replacement_items)
        @waste << Item.new(item.name, waste_qty) if waste_qty != 0
      end
    end

    # Add remaining stock item to waste
    @stock.each do |stock_item|
      next if stock_item.quantity == 0
      @waste << stock_item
    end

    # combine waste items
    w1 = @waste.group_by do |waste_item|
      waste_item.name
    end
    @waste = w1.map do |name, waste_items|
      qty = waste_items.sum { |waste_item| waste_item.quantity }
      Item.new(name, qty)
    end.sort_by(&:name)
  end

  def consume_from_stock
    @stock.each do |stock_item|
      @resolved_rxn.input_items.each do |input_item|
        next if stock_item.quantity == 0
        next if stock_item.name != input_item.name

        consume = [stock_item.quantity, input_item.quantity].min
        input_item.quantity -= consume
        stock_item.quantity -= consume
      end
    end
  end

  def resolve_item?
    resolve_items = []
    @resolved_rxn.input_items.each do |input_item|
      resolve = true
      if input_item.name == "ORE"
        resolve = false
        next
      end
      @resolved_rxn.input_items.each do |another_input_item|
        next if input_item.name == another_input_item.name

        if @graph_full[input_item.name].include?(another_input_item.name)
          resolve = false
        end
      end

      resolve_items << input_item if resolve
    end

    resolve_items
  end

  # 5 ORE => 2A
  # requirement for (3A) = 10 ORE because
  # 10 ORE produces 4 A with 1 wasted A
  def requirement_for(output_item)
    return [] if output_item.name == "ORE"

    reaction = @reactions.find { |reaction| reaction.output_item.name == output_item.name }
    required_qty = output_item.quantity # 3
    reaction_qty = reaction.output_item.quantity # 2

    loop do
      if required_qty % reaction_qty == 0
        break
      end

      required_qty += 1
    end

    multiplier = required_qty / reaction_qty
    required_input = reaction.input_items.map do |input_item|
      input_item.dup.tap { |i| i.quantity *= multiplier }
    end

    waste_output_qty = required_qty - output_item.quantity

    # [required_input, waste_output]
    [required_input, waste_output_qty]
  end
end

class Solution
  MAX = 1_000_000_000_000

  attr_reader :fuel_count

  def initialize(input)
    @input = input
    @rxns = reactions(input)
    @all_wastes = {}

    @fuel_count = 0
    @ore_count = 0
    @all_wastes[[]] = [@fuel_count, @ore_count]
    @waste = []

    # HERE
    @graph = Hash.new { |h, k| h[k] = Set.new }
    @rxns.each do |reaction|
      reaction.input_items.each do |input_item|
        @graph[input_item.name] << reaction.output_item.name
      end
    end

    @graph_full = {}
    @graph.each do |item_name, _|
      @graph_full[item_name] = dependencies_for(item_name)
    end

    @fuel_rxn = @rxns.find { |rxn| rxn.output_item.name == "FUEL" }
  end

  def run
    resolver = nil
    fuels = (0..MAX).bsearch do |fuel_count|
      resolver = Resolver.new(@rxns, @waste, @graph_full, @fuel_rxn, fuel_count: fuel_count)
      resolver.resolve
      resolver.ore_count > MAX
    end

    @fuel_count = fuels - 1 # fuels has just over MAX
    @ore_count = resolver.ore_count
  end

  def to_s
    "Fuels #{@fuel_count}, Ore_count #{@ore_count}" # , Waste #{@waste}"
  end

  private

  def str_to_item(str)
    qty, name = str.split(" ")
    qty = qty.to_i
    Item.new(name, qty)
  end

  def reactions(input)
    input.map do |reaction_string|
      inp, oup = /(.+) => (.+)/.match(reaction_string)[1..2]
      output_item = str_to_item(oup)

      input_items = inp.split(", ").map do |inp_str|
        str_to_item(inp_str)
      end

      Reaction.new(input_items, output_item)
    end
  end

  def dependencies_for(item_name)
    return [] if item_name == "FUEL"

    # it's direct dependencies
    # plus indirect subdependencies
    deps = Set.new

    direct_dependencies = @graph[item_name]
    indirect_dependencies = Set.new
    direct_dependencies.each do |sub_item_name|
      indirect_dependencies.merge(dependencies_for(sub_item_name))
    end

    deps.merge(direct_dependencies)
    deps.merge(indirect_dependencies)
    deps
  end
end

class ResolverTest < Minitest::Test
  def test_p2
    input = File.readlines("input_eg1").map(&:chomp)
    rxns = reactions(input)
    resolver = Resolver.new(rxns, fuel_cnt: 2)
    resolver.resolve

    puts resolver.ore_count
  end

  def test_eg1
    input = File.readlines("input_eg1").map(&:chomp)
    rxns = reactions(input)
    resolver = Resolver.new(rxns)
    resolver.resolve

    assert_equal 31, resolver.ore_count
    assert_equal [Item.new("A", 2)], resolver.waste
  end

  def test_eg1_with_stock
    input = File.readlines("input_eg1").map(&:chomp)
    rxns = reactions(input)
    stock = [Item.new("A", 1)]
    resolver = Resolver.new(rxns, stock)
    resolver.resolve

    assert_equal 31, resolver.ore_count
    assert_equal [Item.new("A", 1)], resolver.waste
  end

  def test_eg1_with_stock_2
    input = File.readlines("input_eg1").map(&:chomp)
    rxns = reactions(input)
    stock = [Item.new("A", 27)]
    resolver = Resolver.new(rxns, stock)
    resolver.resolve

    assert_equal 11, resolver.ore_count
    assert_equal [Item.new("A", 9)], resolver.waste
  end

  def test_eq1_with_stock3
    input = File.readlines("input_eg1").map(&:chomp)
    rxns = reactions(input)
    stock = [Item.new("A", 27), Item.new("B", 4), Item.new("B", 20)]
    resolver = Resolver.new(rxns, stock)
    resolver.resolve

    assert_equal 10, resolver.ore_count
    assert_equal [Item.new("A", 9), Item.new("B", 23)], resolver.waste
  end
end

class SolnTest < Minitest::Test
  def test_neg1
    input = File.readlines("input_eg1").map(&:chomp)
    soln = Solution.new(input)

    soln.run
    puts soln
  end

  def test_neg2
    input = File.readlines("input_eg2").map(&:chomp)
    soln = Solution.new(input)

    soln.run
    puts soln
  end

  def test_neg3
    input = File.readlines("input_eg3").map(&:chomp)
    soln = Solution.new(input)

    soln.run
    puts soln
    puts soln.trillian_ore_fuel
  end

  def test_neg4
    input = File.readlines("input_eg4").map(&:chomp)
    soln = Solution.new(input)

    soln.run
    puts soln
    puts soln.trillian_ore_fuel
  end

  def test_neg5
    input = File.readlines("input_eg5").map(&:chomp)
    soln = Solution.new(input)

    soln.run
    puts soln
    # (target: 460664)
  end

  # Part2 solution
  def test_neg_part2
    input = File.readlines("input").map(&:chomp)
    soln = Solution.new(input)

    soln.run
    puts soln
    assert_equal 1376631, soln.fuel_count
  end
end
