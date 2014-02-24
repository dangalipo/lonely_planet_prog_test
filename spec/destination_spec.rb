require "destination"
require "nokogiri"

describe Destination do

  describe ".initialize" do

    let(:id)      { 1 }
    let(:name)    { "test" }
    let(:parent)  { Object.new }

    subject(:new_destination) { Destination.new(id, name, parent) }

    specify { expect(new_destination.id).to eq id }
    specify { expect(new_destination.name).to eq name }
    specify { expect(new_destination.parent).to eq parent }
    specify { expect(new_destination.children).to be_empty }
    specify { expect(new_destination.content).to be_empty }

  end

  describe ".create_from_node" do

    let(:document) { Nokogiri::XML::Document.new }
    let(:node)     { Nokogiri::XML::Node.new("node", document) }
    let(:parent)   { Object.new }

    subject(:create_from_node) { Destination.create_from_node(node, parent) }

    context "node does not have the specified unique id attribute" do

      specify { expect{create_from_node}.to raise_error(InvalidNode, "atlas_node_id not found") }

    end

    context "node has the specified unique id attribute" do

      let(:id)      { "1" }
      let(:name)    { 'test' }
      before(:each) { node["atlas_node_id"] = id }

      context "and does not have the a 'node_name' node in it's children" do

        specify { expect{create_from_node}.to raise_error(InvalidNode, "node_name node not found") }

      end

      context "and has a single 'node_name' node in it's children" do

        before(:each) do
          name_node = Nokogiri::XML::Node.new("node_name", document)
          name_node.content = name
          node <<  name_node
        end

        specify { expect(create_from_node.id).to eq id }
        specify { expect(create_from_node.name).to eq name }
        specify { expect(create_from_node.parent).to eq parent }
        specify { expect(create_from_node.children).to be_empty }
        specify { expect(create_from_node.content).to be_empty }

      end

      context "and has multiple 'node_name' nodes in it's children" do

        before(:each) do
          2.times do |i|
            name_node = Nokogiri::XML::Node.new("node_name", document)
            name_node.content = "#{name} #{i}"
            node <<  name_node
          end
        end

        specify { expect{create_from_node}.to raise_error(InvalidNode, "multiple node_name nodes found") }

      end

    end

  end

end