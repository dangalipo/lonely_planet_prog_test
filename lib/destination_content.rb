class DestinationContent

  UNIQUE_ID_ATTRIBUTE = 'atlas_id'

  attr_reader :title, :content, :children, :parent

  def initialize(title, parent)
    self.title = title
    self.content = []
    self.parent = parent
    self.children = []
  end

private

  attr_writer :title, :content, :children, :parent


end