module NodeHelpers

private

  def find_node_in_children_by_name(node, name)
    node.children.find{ |node| node.name == name }
  end

end