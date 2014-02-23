class DestinationContent

  attr_reader :title, :content, :children, :parent

  def initialize(title, content, parent)
    self.title = title
    self.content = content
    self.parent = parent
    self.children = []
  end

private

  attr_writer :title, :content, :children, :parent


end