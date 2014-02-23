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
    create_content(root)
    destinations
  end

private

  attr_accessor :parsed_document, :destinations

  def create_content(node)
    destination_content_nodes = sanitize_children(node.children)
    destination_content_nodes.each do |node|
      if destinations[node[DestinationContent::UNIQUE_ID_ATTRIBUTE]].nil?
        raise InvalidContent.new("Could not find a destination matching #{Destination::UNIQUE_ID_ATTRIBUTE} #{node[DestinationContent::UNIQUE_ID_ATTRIBUTE]}.")
      end
      destinations[node[DestinationContent::UNIQUE_ID_ATTRIBUTE]].content << compile_content(node)
    end
  end

  # Uses the XML document to build a similar tree of DestinationContent objects
  def compile_content(node, parent_content = nil)
    sanitize_children(node.children).each do |node|
      destination_content = DestinationContent.new(node.name, parent_content)
      destination_content.content << node.content
      destination_content.children << compile_content(node, destination_content)
    end
    destination_content
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