require 'logger'

require 'supernova/version'
require 'supernova/project'
require 'supernova/constructor'
require 'supernova/exceptions'
require 'supernova/remote'
require 'supernova/star'

require 'supernova/starbound'

# A Game management software.  Also note that a method named
# +Supernova+ is available under the top-level namespace, which acts
# as an alias for {Supernova.create}.
#
# @api public
module Supernova

  # The Supernova logger.  By default outputs to STDOUT.
  #
  # @return {Logger}
  def self.logger
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
  def self.create(options, &block)
    Constructor.new(options, &block).modify_or_create
  end
end

# Creates or modifies a star, with the given options and block.
#
# @see Supernova.create
# @param (see Supernova.create)
# @yield (see Supernova.create)
# @return [Class] the new star.
def Supernova(options, &block)
  Supernova.create(options, &block)
end
