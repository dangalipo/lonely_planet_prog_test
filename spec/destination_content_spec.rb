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

end