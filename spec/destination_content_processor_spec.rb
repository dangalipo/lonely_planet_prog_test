require 'destination_content_processor'

describe DestinationContentProcessor do
  describe "process" do


    let(:processor) { DestinationContentProcessor.new(filename, destinations) }

    subject(:process) { processor.process }

    context "content file is is valid XML" do

      # Please consult spec/support/example_content.xml as a reference for these static values

      let(:filename)  { File.join(Dir.pwd, "spec", "support", "example_content.xml") }

      context "destination does not exist for an id" do

        let(:destinations) { {} }

        specify { expect{process}.to raise_error(InvalidContent, "Could not find a destination matching atlas_node_id 355064.") }

      end

      context "destination exists for an id" do

        let(:destination)  { Destination.new("355064", "Africa", nil) }
        let(:destinations) { { "355064" => destination } }

        context 'Top level content' do

          subject(:top_level_content) { process; destination.content }

          specify { expect(top_level_content.count).to eq 2 }
          specify { expect(top_level_content.collect(&:title)).to include "history" }
          specify { expect(top_level_content.collect(&:title)).to include "practical_information" }
          specify { expect(top_level_content.first.content).to be_empty }
          specify { expect(top_level_content.last.content).to be_empty }
          specify { expect(top_level_content.first.children.count).to eq 1 }
          specify { expect(top_level_content.last.children.count).to eq 1 }

          context 'first level child content' do

            subject(:first_level_child_content) { top_level_content.collect(&:children).flatten }

            specify { expect(first_level_child_content.count).to eq 2 }
            specify { expect(first_level_child_content.collect(&:title)).to include "history" }
            specify { expect(first_level_child_content.collect(&:title)).to include "health_and_safety" }
            specify { expect(first_level_child_content.first.content).to be_empty }
            specify { expect(first_level_child_content.last.content).to be_empty }
            specify { expect(first_level_child_content.first.children.count).to eq 1 }
            specify { expect(first_level_child_content.last.children.count).to eq 2 }

            context 'bottom level content' do

              subject(:bottom_level_content) { first_level_child_content.collect(&:children).flatten }

              specify { expect(bottom_level_content.count).to eq 3 }

              specify { expect(bottom_level_content.collect(&:title)).to include "history" }
              specify { expect(bottom_level_content.collect(&:title)).to include "before_you_go" }
              specify { expect(bottom_level_content.collect(&:title)).to include "dangers_and_annoyances" }

              specify { expect(bottom_level_content.first.content.count).to eq 2 }
              specify { expect(bottom_level_content.first.content).to include "Some history content" }
              specify { expect(bottom_level_content.first.content).to include "Some more history content" }

              specify { expect(bottom_level_content[1].content.count).to eq 2 }
              specify { expect(bottom_level_content[1].content).to include "Some before you go content" }
              specify { expect(bottom_level_content[1].content).to include "Some more before you go content" }

              specify { expect(bottom_level_content[2].content.count).to eq 1 }
              specify { expect(bottom_level_content[2].content).to include "Some danger and annoyances content" }

              specify { expect(bottom_level_content.collect(&:children).flatten).to be_empty }

            end

          end

        end

      end

    end

    context "content file is not valid XML" do


      let(:destinations) { {} }
      let(:filename)     { File.join(Dir.pwd, "spec", "support", "invalid_xml.xml") }

      specify { expect{process}.to raise_error(InvalidContent, "Content file XML could not be parsed") }

    end

  end

end