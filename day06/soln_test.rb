input = File.new("input").readlines
# input = DATA.readlines
input = input.map(&:chomp)

Node = Struct.new(:parent, :children, :cnt)

nodes = {}

input.each do |i|
  x, y = i.split(")")

  # itself
  if !nodes[x]
    node = Node.new(nil, [])
    nodes[x] = node
  else
    node = nodes[x]
  end

  # child
  if !nodes[y]
    child = Node.new(node, [])
    nodes[y] = child
  else
    child = nodes[y]
    child.parent = node
    node.children << child
  end
end

def orbit_count(node)
  if node.cnt
    # noop
  elsif node.parent.nil?
    node.cnt = 0
  else
    node.cnt = orbit_count(node.parent) + 1
  end
  node.cnt
end

# part1 calculate orbit_count_for_all_nodes
ans1 = 0
nodes.each do |k, node|
  ans1 += orbit_count(node)
end
p ans1

# Part2
def parents(node)
  parents = []
  return parents if node.parent.nil?

  parents << node.parent
  parents.concat(parents(node.parent))

  return parents
end

nYou = nodes["YOU"]
nSan = nodes["SAN"]

pYou = parents(nYou)
pSan = parents(nSan)

nCommon = (pYou & pSan)[0]

ans2 = (nYou.cnt - nCommon.cnt) + (nSan.cnt - nCommon.cnt) - 2
p ans2

__END__
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
K)YOU
I)SAN
