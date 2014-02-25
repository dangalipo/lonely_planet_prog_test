require 'destination_renderer'
require 'destination'
require 'destination_content'

describe DestinationRenderer do

  describe "#render" do

    before(:each)     { stub_const("DestinationRenderer::TEMPLATE", "spec/support/example_template.html") }
    let(:id)          { 1 }
    let(:name)        { 'test' }
    let(:parent)      { nil }
    let(:destination) { Destination.new(id, name, parent) }

    subject(:render_destination) { DestinationRenderer.new(destination).render }

    context "inserting destination name" do

      specify { expect(render_destination).to include "<div id=\"name\">test</div>"}

    end

    context "inserting destination navigation" do

      context "destination is a top level node" do

        # parent is already nil
        let(:first_child_id)            { 2 }
        let(:first_child_name)          { "First Child" }
        let!(:first_child_destination)  { Destination.new(first_child_id, first_child_name, destination) }

        let(:second_child_id)           { 3 }
        let(:second_child_name)         { "Second Child" }
        let!(:second_child_destination) { Destination.new(second_child_id, second_child_name, destination) }

        let(:expected_child_navigation) do
          [
            "<h4>Sub Regions</h4>",
            "<ul>",
            "<li><a href=\"#{first_child_id}\">#{first_child_name}</a></li>",
            "<li><a href=\"#{second_child_id}\">#{second_child_name}</a></li>",
            "</ul>"].join("\n")
        end

        before(:each) { destination.children.concat([first_child_destination, second_child_destination]) }

        specify { expect(render_destination).to include "<div id=\"nav\">#{expected_child_navigation}</div>" }

      end

      context "destination is a mid level node" do

        let(:parent_id)   { "4" }
        let(:parent_name) { "Parent" }
        let(:parent)      { Destination.new(parent_id, parent_name, nil)}

        let(:first_child_id)            { 2 }
        let(:first_child_name)          { "First Child" }
        let!(:first_child_destination)  { Destination.new(first_child_id, first_child_name, destination) }

        let(:second_child_id)           { 3 }
        let(:second_child_name)         { "Second Child" }
        let!(:second_child_destination) { Destination.new(second_child_id, second_child_name, destination) }

        let(:expected_parent_navigation) do
          [
            "<h4>Parent Regions</h4>",
            "<ul>",
            "<li><a href=\"#{parent_id}\">#{parent_name}</a></li>",
            "</ul>"].join("\n")
        end

        let(:expected_child_navigation) do
          [
            "<h4>Sub Regions</h4>",
            "<ul>",
            "<li><a href=\"#{first_child_id}\">#{first_child_name}</a></li>",
            "<li><a href=\"#{second_child_id}\">#{second_child_name}</a></li>",
            "</ul>"].join("\n")
        end

        before(:each) do
          parent.children << destination
          destination.children.concat([first_child_destination, second_child_destination])
        end

        specify { expect(render_destination).to include "<div id=\"nav\">#{expected_parent_navigation}\n#{expected_child_navigation}</div>" }

      end

      context "destination is a bottom level node" do

        let(:grandparent_id)   { "4" }
        let(:grandparent_name) { "Parent" }
        let(:grandparent)      { Destination.new(parent_id, parent_name, nil)}

        let(:parent_id)        { "4" }
        let(:parent_name)      { "Parent" }
        let(:parent)           { Destination.new(parent_id, parent_name, grandparent)}

        let(:expected_parent_navigation) do
          [
            "<h4>Parent Regions</h4>",
            "<ul>",
            "<li><a href=\"#{grandparent_id}\">#{grandparent_name}</a></li>",
            "<li><a href=\"#{parent_id}\">#{parent_name}</a></li>",
            "</ul>"].join("\n")
        end

        before(:each) do
          grandparent.children << parent
          parent.children << destination
        end

        specify { expect(render_destination).to include "<div id=\"nav\">#{expected_parent_navigation}</div>" }


      end

    end

    context "inserting destination content" do

      let(:first_top_level_content_title)         { "First Top Level Content" }
      let(:first_top_level_content)               { DestinationContent.new(first_top_level_content_title, nil ) }
      let(:second_top_level_content_title)        { "Second Top Level Content" }
      let(:second_top_level_content)              { DestinationContent.new(second_top_level_content_title, nil ) }

      let(:first_mid_level_content_title)         { "First Mid Level Content" }
      let(:first_mid_level_content)               { DestinationContent.new(first_mid_level_content_title, first_top_level_content ) }
      let(:second_mid_level_content_title)        { "Second Mid Level Content" }
      let(:second_mid_level_content)              { DestinationContent.new(second_mid_level_content_title, second_top_level_content ) }

      let(:first_bottom_level_content_title)      { "First Bottom Level Content" }
      let(:first_bottom_level_content_text_one)   { "First Bottom Level Content Text" }
      let(:first_bottom_level_content_text_two)   { "First Bottom Level Content Other Text" }
      let(:first_bottom_level_content)            { DestinationContent.new(first_bottom_level_content_title, first_mid_level_content ) }
      let(:second_bottom_level_content_title)     { "Second Bottom Level Content" }
      let(:second_bottom_level_content_text)      { "Second Bottom Level Content Text" }
      let(:second_bottom_level_content)           { DestinationContent.new(second_bottom_level_content_title, second_mid_level_content ) }
      let(:third_bottom_level_content_title)      { "Third Bottom Level Content" }
      let(:third_bottom_level_content_text)       { "Third Bottom Level Content Text" }
      let(:third_bottom_level_content)            { DestinationContent.new(third_bottom_level_content_title, second_mid_level_content ) }

      let(:expected_content) do
        content = [
          "<h1>#{first_top_level_content_title}</h1>",
          "<h2>#{first_mid_level_content_title}</h2>",
          "<h3>#{first_bottom_level_content_title}</h3>",
          "<p>#{first_bottom_level_content_text_one}</p>",
          "<p>#{first_bottom_level_content_text_two}</p>",
          "<h1>#{second_top_level_content_title}</h1>",
          "<h2>#{second_mid_level_content_title}</h2>",
          "<h3>#{second_bottom_level_content_title}</h3>",
          "<p>#{second_bottom_level_content_text}</p>",
          "<h3>#{third_bottom_level_content_title}</h3>",
          "<p>#{third_bottom_level_content_text}</p>"
        ]
        "<div id=\"content\">#{content.join("\n")}</div>"
      end

      before(:each) do
        destination.content.concat([first_top_level_content, second_top_level_content])

        first_top_level_content.children << first_mid_level_content
        second_top_level_content.children << second_mid_level_content

        first_mid_level_content.children << first_bottom_level_content
        second_mid_level_content.children.concat([second_bottom_level_content, third_bottom_level_content])

        first_bottom_level_content.content.concat([first_bottom_level_content_text_one, first_bottom_level_content_text_two])
        second_bottom_level_content.content << second_bottom_level_content_text
        third_bottom_level_content.content << third_bottom_level_content_text
      end

      specify { expect(render_destination).to include expected_content }

    end

  end

end