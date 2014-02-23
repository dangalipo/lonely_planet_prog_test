require 'destination_taxonomy_processor'

describe DestinationTaxonomyProcessor do

  describe "process" do

    let(:filename) { File.join(Dir.pwd, "spec", "support", "example_taxonomy.xml") }
    let(:processor) { DestinationTaxonomyProcessor.new(filename) }

    subject(:process) { processor.process }

    # Please consult spec/support/example_taxonomy.xml as a reference for these static values

    context "destinations keys" do

      specify { expect(process.keys).to include "355064" }
      specify { expect(process.keys).to include "355629" }
      specify { expect(process.keys).to include "355630" }
      specify { expect(process.keys).to include "355632" }
      specify { expect(process.keys).to include "355633" }
      specify { expect(process.keys.length).to eq 5 }

    end

    context "top level destination" do

      subject(:top_level_destination) { process["355064"] }

      specify { expect(top_level_destination.id).to eq "355064" }
      specify { expect(top_level_destination.name).to eq "Africa" }
      specify { expect(top_level_destination.parent).to be_nil }
      specify { expect(top_level_destination.children.count).to eq 2 }
      specify { expect(top_level_destination.children.collect(&:id)).to include "355629" }
      specify { expect(top_level_destination.children.collect(&:id)).to include "355633" }
      specify { expect(top_level_destination.content).to be_nil }

    end

    context "first level child destinations" do

      subject(:first_level_child_destination) { process["355629"] }

      specify { expect(first_level_child_destination.id).to eq "355629" }
      specify { expect(first_level_child_destination.name).to eq "Sudan" }
      specify { expect(first_level_child_destination.parent.id).to eq "355064" }
      specify { expect(first_level_child_destination.children.count).to eq 2 }
      specify { expect(first_level_child_destination.children.collect(&:id)).to include "355630" }
      specify { expect(first_level_child_destination.children.collect(&:id)).to include "355632" }
      specify { expect(first_level_child_destination.content).to be_nil }

    end

    context "bottom level child destinations" do

      subject(:bottom_level_child_destination) { process["355632"] }

      specify { expect(bottom_level_child_destination.id).to eq "355632" }
      specify { expect(bottom_level_child_destination.name).to eq "Khartoum" }
      specify { expect(bottom_level_child_destination.parent.id).to eq "355629" }
      specify { expect(bottom_level_child_destination.children).to be_empty }
      specify { expect(bottom_level_child_destination.content).to be_nil }

    end


  end


end