require 'nokogiri'
require_relative 'destination'
require_relative 'destination_content'

class InvalidContent < StandardError; end

class DestinationContentProcessor

  def initialize(content_filename, destinations)
    self.parsed_document = Nokogiri::XML(File.open(content_filename))
    self.destinations = destinations
  end

  def process
    root = find_node_in_children_by_name(parsed_document, "destinations")
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
    if node.name != '#cdata-section'

      destination_content = parent_content.children.find {|content| content.title == node.name } unless parent_content.nil?
      destination_content = DestinationContent.new(node.name, parent_content) if destination_content.nil?

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

  # The below methods could be monkey patched onto Nokogiri::XML::Node and Nokogiri::XML::Document
  # however, given the size of this project, I do not feel the benefit from the separation of responsibility
  # is worth the readability cost of altering the documented interface for these two classes.

  def find_node_in_children_by_name(node, name)
    node.children.find{ |node| node.name == name }
  end

  # Removes any <Nokogiri::XML::Text:0x3fccd5c52948 "\n"> nodes caused by prettifying the XML document
  def sanitize_children(children)
    children.reject{|node| node.name == "text" && node.content.strip.empty?}
  end

end