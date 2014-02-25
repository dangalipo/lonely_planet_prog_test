require "destination_content"
require "nokogiri"

describe DestinationContent do

  describe ".initialize" do

    let(:title)   { "Test Title" }
    let(:parent)  { Object.new }

    subject(:new_destination_content) { DestinationContent.new(title, parent) }

    specify { expect(new_destination_content.title).to eq title }
    specify { expect(new_destination_content.content).to be_empty }
    specify { expect(new_destination_content.parent).to eq parent }
    specify { expect(new_destination_content.children).to be_empty }

  end

  describe ".find_or_create_destination_content" do

    shared_examples_for "a new DestinationContent is created" do

      specify { expect(find_or_create_destination_content).to be_a DestinationContent }
      specify { expect(find_or_create_destination_content.title).to eq name }
      specify { expect(find_or_create_destination_content.parent).to eq parent }

    end

    let(:name) { "Test" }

    subject(:find_or_create_destination_content) { DestinationContent.find_or_create_destination_content(name, parent) }

    context "parent is nil" do

      let(:parent)              { nil }

      it_behaves_like "a new DestinationContent is created"

    end

    context "parent is not nil" do

      let(:parent)              { DestinationContent.new("Parent", nil) }
      let(:destination_content) { DestinationContent.new(existing_name, parent) }

      before(:each)             { parent.children << destination_content }

      context "and already has a node with the same name" do

        let(:existing_name) { name }

        specify { expect(find_or_create_destination_content).to eq destination_content }

      end

      context "and doesn't have a node with the same name" do

        let(:existing_name) { "Other Name" }

        let(:destination_content) { DestinationContent.new(existing_name, nil) }

        it_behaves_like "a new DestinationContent is created"
        specify { expect(find_or_create_destination_content).not_to eq destination_content }

      end


    end


  end

end