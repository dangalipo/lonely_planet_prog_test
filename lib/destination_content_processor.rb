require 'nokogiri'
require_relative 'destination'
require_relative 'destination_content'
require_relative 'node_helpers'

class InvalidContent < StandardError; end

class DestinationContentProcessor

  include NodeHelpers

  def initialize(content_filename, destinations)
    self.parsed_document = Nokogiri::XML(File.open(content_filename))
    self.destinations = destinations
  end

  def process
    raise InvalidContent.new("Content file XML could not be parsed") unless parsed_document.errors.empty?
    root = find_node_in_children_by_name(parsed_document, "destinations")
    raise InvalidContent.new("Could not find root destinations node in the provided content file") if root.nil?
    sanitize_children(root.children).each do |node|
      create_content(node)
    end
    destinations
  end

private

  attr_accessor :parsed_document, :destinations

  def create_content(node)
    destination_id = node[DestinationContent::UNIQUE_ID_ATTRIBUTE]
    raise InvalidContent.new("Could not find a destination matching #{Destination::UNIQUE_ID_ATTRIBUTE} #{destination_id}.") if destinations[destination_id].nil?
    destination_content_nodes = sanitize_children(node.children)
    destination_content_nodes.each do |node|
      destinations[destination_id].content << compile_content(node)
    end
  end

  # Uses the XML document to build a similar tree of DestinationContent objects
  def compile_content(node, parent_content = nil)
    if !node_contains_content?(node)
      destination_content = DestinationContent.find_or_create_destination_content(node.name, parent_content)

      sanitize_children(node.children).each do |node|
        child = compile_content(node, destination_content)
        destination_content.children << child unless child.nil? || destination_content.children.include?(child)
      end

      destination_content
    else
      parent_content.content << node.content if node.children.empty?
      nil
    end
  end

  # Returns true if the node contains content text rather than just being a link in the
  # content tree structure
  # i.e.
  # <foo>
  #   <bar>
  #     <![CDATA[Some content about a lovely place in the world]]>
  #   </bar>
  # </foo>
  #
  def node_contains_content?(node)
    node.name == '#cdata-section'
  end

  # Removes any <Nokogiri::XML::Text:0x3fccd5c52948 "\n"> nodes caused by prettifying the XML document
  def sanitize_children(children)
    children.reject{|node| node.name == "text" && node.content.strip.empty?}
  end

end