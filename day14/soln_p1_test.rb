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


class Solution
  # Graph and Node
  Node = Struct.new(:name, :children)
  attr_reader :final_reaction

  def initialize(reactions)
    @graph = Hash.new { |h, k| h[k] = Set.new }
    @reactions = reactions
    reactions.each do |reaction|
      reaction.input_items.each do |input_item|
        @graph[input_item.name] << reaction.output_item.name
      end
    end

    full_graph
    @final_reaction = resolve
  end

  def resolve
    fuel_rxn = @reactions.find { |rxn| rxn.output_item.name == "FUEL" }.dup

    loop do
      items = resolve_item?(fuel_rxn)
      break if items.empty?

      items.each do |item|
        replacement_items = requirement_for(item)
        fuel_rxn.replace(item, replacement_items)
      end
    end

    fuel_rxn
  end

  def resolve_item?(reaction)
    resolve_items = []
    reaction.input_items.each do |input_item|
      resolve = true
      if input_item.name == "ORE"
        resolve = false
        next
      end
      reaction.input_items.each do |another_input_item|
        next if input_item.name == another_input_item.name

        if @graph_full[input_item.name].include?(another_input_item.name)
          resolve = false
        end
      end

      resolve_items << input_item if resolve
    end

    resolve_items
  end

  def full_graph
    @graph_full = {}
    @graph.each do |item_name, _|
      @graph_full[item_name] = dependencies_for(item_name)
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
    reaction.input_items.map do |input_item|
      input_item.dup.tap { |i| i.quantity *= multiplier }
    end
  end
end


class SolnTest < Minitest::Test
  def test_eg1
    input = File.readlines("input_eg1").map(&:chomp)
    rxns = reactions(input)
    soln = Solution.new(rxns)

    final_ore_input = soln.final_reaction.input_items.first
    assert_equal 31, final_ore_input.quantity
  end

  def test_eg2
    input = File.readlines("input_eg2").map(&:chomp)
    rxns = reactions(input)
    soln = Solution.new(rxns)

    final_ore_input = soln.final_reaction.input_items.first
    assert_equal 165, final_ore_input.quantity
  end

  def test_eg3
    input = File.readlines("input_eg3").map(&:chomp)
    rxns = reactions(input)
    soln = Solution.new(rxns)

    final_ore_input = soln.final_reaction.input_items.first
    assert_equal 13312, final_ore_input.quantity
  end

  def test_eg4
    input = File.readlines("input_eg4").map(&:chomp)
    rxns = reactions(input)
    soln = Solution.new(rxns)

    final_ore_input = soln.final_reaction.input_items.first
    assert_equal 180697, final_ore_input.quantity
  end

  def test_eg5
    input = File.readlines("input_eg5").map(&:chomp)
    rxns = reactions(input)
    soln = Solution.new(rxns)

    final_ore_input = soln.final_reaction.input_items.first
    assert_equal 2210736, final_ore_input.quantity
  end
end
