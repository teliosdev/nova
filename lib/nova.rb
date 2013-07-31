require 'logger'

require 'nova/version'
require 'nova/project'
require 'nova/constructor'
require 'nova/exceptions'
require 'nova/remote'
require 'nova/star'
require 'nova/shell'

require 'nova/starbound'

# A Game management software.  Also note that a method named
# +Nova+ is available under the top-level namespace, which acts
# as an alias for {Nova.create}.
#
# @api public
module Nova

  # The Nova logger.  By default outputs to STDOUT.
  #
  # @return {Logger}
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  class << self
    attr_writer :logger
  end

  # This creates a star with a given block, unless it already exists;
  # if it does, it just modifies that star.
  #
  # @param options [Hash{Symbol => Symbol}] the first key value pair
  #   is used to determine the star type and star name, while the
  #   rest is ignored.
  # @yield [] to create the star.
  # @return [Class] the new star.
  def self.create(options, &block)
    Constructor.new(options, &block).modify_or_create
  end
end

# Creates or modifies a star, with the given options and block.
#
# @see Nova.create
# @param (see Nova.create)
# @yield (see Nova.create)
# @return [Class] the new star.
def Nova(options, &block)
  Nova.create(options, &block)
end
