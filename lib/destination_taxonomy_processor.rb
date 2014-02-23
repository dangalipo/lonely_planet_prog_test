require 'nokogiri'
require_relative 'destination'

class DestinationTaxonomyProcessor


  def initialize(taxonomy_filename)
    self.parsed_document = Nokogiri::XML(File.open(taxonomy_filename))
    self.destinations = {}
  end

  def process
    taxonomies = find_node_in_children_by_name(parsed_document, "taxonomies")
    taxonomy =  find_node_in_children_by_name(taxonomies, "taxonomy")
    create_destinations(taxonomy)
    destinations
  end

private

  attr_accessor :parsed_document, :destinations

  def create_destinations(node, parent_destination = nil)
    destination_nodes = node.children.select{|node| node.name == "node" }
    destination_nodes.each do |node|
      destination = Destination.create_from_node(node, parent_destination)
      destinations[destination.id] = destination
      parent_destination.children << destination unless parent_destination.nil?
      create_destinations(node, destination)
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
    reject{|node| node.name == "text" && node.content.strip.empty?}
  end

end