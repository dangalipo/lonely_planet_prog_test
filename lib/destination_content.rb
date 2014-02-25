class DestinationContent

  UNIQUE_ID_ATTRIBUTE = 'atlas_id'

  attr_reader :title, :content, :children, :parent

  def initialize(title, parent)
    self.title = title
    self.content = []
    self.parent = parent
    self.children = []
  end

  def self.find_or_create_destination_content(node_name, parent_content)
    destination_content = parent_content.children.find {|content| content.title == node_name } unless parent_content.nil?
    destination_content || DestinationContent.new(node_name, parent_content)
  end

private

  attr_writer :title, :content, :children, :parent


end