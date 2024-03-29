require_relative "destination_taxonomy_processor"
require_relative "destination_content_processor"
require_relative "destination_renderer"

class InvocationError < ArgumentError; end
class DestinationBatchProcessor

  TEMPLATE_ASSETS = 'templates/static'

  def initialize(args)
    validate_args(args)
    self.taxonomy_filename = args[0]
    self.destination_content_filename = args[1]
    self.output_dir = args[2]
  end

  def process
    puts "Processing destinations..."
    destinations = DestinationTaxonomyProcessor.new(taxonomy_filename).process
    puts "Processing content..."
    DestinationContentProcessor.new(destination_content_filename, destinations).process
    puts "Generating output html..."
    destinations.values.each do |destination|
      content = DestinationRenderer.new(destination).render
      File.write(File.join(output_dir, "#{destination.id}.html"), content)
    end
    static_assets = File.join(File.expand_path(File.dirname(__FILE__)),TEMPLATE_ASSETS)
    `cp -r #{static_assets} #{output_dir}`
  end

private

  attr_accessor :taxonomy_filename, :destination_content_filename, :output_dir

  def validate_args(args)
    raise InvocationError.new("Expected arguments: <taxonomy file>, <destination content file>, <output dir>") unless args.length == 3
    raise InvocationError.new("Taxonomy File #{args[0]} does not exist") unless File.exists?(args[0])
    raise InvocationError.new("Destination Content File #{args[1]} does not exist") unless File.exists?(args[1])
    raise InvocationError.new("Output Directory #{args[2]} does not exist") unless Dir.exists?(args[2])
  end

end