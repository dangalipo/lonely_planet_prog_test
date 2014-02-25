require 'nokogiri'
require_relative 'destination'
require_relative 'node_helpers'

class InvalidTaxonomy < StandardError; end

class DestinationTaxonomyProcessor

  include NodeHelpers

  def initialize(taxonomy_filename)
    self.parsed_document = Nokogiri::XML(File.open(taxonomy_filename))
    self.destinations = {}
  end

  def process
    raise InvalidTaxonomy.new("Content file XML could not be parsed") unless parsed_document.errors.empty?
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

end