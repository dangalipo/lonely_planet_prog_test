require 'destination_content_processor'

describe DestinationContentProcessor do
  describe "process" do

    let(:filename)  { File.join(Dir.pwd, "spec", "support", "example_content.xml") }
    let(:processor) { DestinationContentProcessor.new(filename, destinations) }

    subject(:process) { processor.process }

    # Please consult spec/support/example_content.xml as a reference for these static values

    context "destination does not exist for an id" do

      let(:destinations) { {} }

      specify { expect{process}.to raise_error(InvalidContent, "Could not find a destination matching atlas_node_id 355064.") }

    end

    context "destination exists for an id" do

      let(:destination)  { Destination.new("355064", "Africa", nil) }
      let(:destinations) { { "355064" => destination } }

      context "child content shares the same title as it's siblings" do

        specify do
          process
          expect(destination.content.count).to eq 2
        end
        specify do
          process
          expect(destination.content.first.title).to eq "history"
        end

        specify do
          process
          expect(destination.content.first.content.count).to eq 2
        end

      end

      context "child content doesn't shares the same title as it's siblings" do

      end

    end

  end

end