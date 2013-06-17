require 'logger'

require 'supernova/version'
require 'supernova/exceptions'
require 'supernova/star'
require 'supernova/constructor'

# A Game management software.
#
# @api public
module Supernova

  # The Supernova logger.  By default outputs to STDOUT.
  #
  # @return {Logger}
  def logger
    @logger ||= Logger.new(STDOUT)
  end

  attr_writer :logger

  # This creates a star with a given block.
  #
  # @param options [Hash{Symbol => Symbol}] it should contain a single
  #   key-value pair.  Any others will be ignored.
  def create(options, &block)
    c = Constructor.new(options, &block).create
    Star.stars[c.as] = c
  end

  extend self
end
