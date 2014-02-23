class InvalidNode < StandardError; end

class Destination

  UNIQUE_ID_ATTRIBUTE = "atlas_node_id"

  attr_accessor :parent, :content
  attr_reader :name, :id, :children

  def initialize(id, name, parent)
    self.id = id
    self.name = name
    self.parent = parent
    self.children = []
    self.content = []
  end

  def self.create_from_node(node, parent_destination)
    validate_node(node)
    id = node.attributes[UNIQUE_ID_ATTRIBUTE].value
    name = node.children.find{ |node| node.name == "node_name" }.content
    new(id, name, parent_destination)
  end

private

  def self.validate_node(node)
    raise InvalidNode.new("#{UNIQUE_ID_ATTRIBUTE} not found") if node.attributes[UNIQUE_ID_ATTRIBUTE].nil?
    node_name_count = node.children.select{ |node| node.name == "node_name" }.count
    raise InvalidNode.new("node_name node not found") if node_name_count == 0
    raise InvalidNode.new("multiple node_name nodes found") if node_name_count > 1
  end

  attr_writer :name, :id, :children


end