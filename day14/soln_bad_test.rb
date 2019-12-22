input = File.readlines("input_eg1").map(&:chomp)

Item = Struct.new(:name, :quantity)
Reaction = Struct.new(:input_items, :output_item)

def str_to_item(str)
  qty, name = str.split(" ")
  qty = qty.to_i
  Item.new(name, qty)
end

reactions = input.map do |reaction_string|
  inp, oup = /(.+) => (.+)/.match(reaction_string)[1..2]
  output_item = str_to_item(oup)

  input_items = inp.split(", ").map do |inp_str|
    str_to_item(inp_str)
  end

  Reaction.new(input_items, output_item)
end

def requirement_for(output_item, reactions)
  reaction = reactions.find { |reaction| reaction.output_item.name == output_item.name }
  required_qty = output_item.quantity

  reaction_qty = reaction.output_item.quantity
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


puts requirement_for(Item.new("A", 10), reactions)
puts requirement_for(Item.new("A", 7), reactions)
puts requirement_for(Item.new("A", 11), reactions)
puts requirement_for(Item.new("A", 21), reactions)
puts requirement_for(Item.new("A", 0), reactions)

def ore_reqn_for(item, reactions)
  requirements = []
  input_items = requirement_for(item, reactions)
  input_items.each do |input_item|
    if input_item.name == "ORE"
      requirements << input_item
    else
      requirements.concat(ore_reqn_for(input_item, reactions))
    end
  end

  requirements
end

puts requirement_for(Item.new("C", 2), reactions)
fuel_item = reactions.find { |r| r.output_item.name == "FUEL" }


puts ore_reqn_for(fuel_item.output_item, reactions)
