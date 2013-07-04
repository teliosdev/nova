require 'logger'

require 'supernova/version'
require 'supernova/project'
require 'supernova/constructor'
require 'supernova/exceptions'
require 'supernova/remote'
require 'supernova/star'

require 'supernova/starbound'

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

  # This creates a star with a given block, unless it already exists;
  # if it does, it just modifies that star.
  #
  # @param options [Hash{Symbol => Symbol}] the first key value pair
  #   is used to determine the star type and star name, while the
  #   rest is ignored unless it's +:required_platforms+.
  # @yield [] to create the star.
  # @return [Class] the new star.
  def create(options, &block)
    Constructor.new(options, &block).modify_or_create
  end

  extend self
end

# see Supernova.create
def Supernova(options, &block)
  Supernova.create(options, &block)
end
