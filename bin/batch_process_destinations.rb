#!/usr/bin/env ruby
require_relative "../lib/destination_batch_processor"

begin
  DestinationBatchProcessor.new(ARGV).process
rescue InvocationError, InvalidNode, InvalidContent, InvalidTaxonomy => e
  puts e.message
end
