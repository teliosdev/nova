require 'supernova/remote/fake/platforms'
require 'supernova/remote/fake/commands'
require 'supernova/remote/fake/filesystem'
require 'supernova/remote/fake/operating_system'

module Supernova

  # Handles managing the system the star will be handing.
  module Remote

    # A fake remote to stub out the default behavior.  This is the
    # default remote for {Star}.
    #
    # @abstract Define all of the methods in this module to create a
    #   workable remote, which can be used for a {Star}.
    module Fake

      include Fake::Platforms
      include Fake::Commands
      include Fake::Filesystem
      include Fake::OperatingSystem

      extend self
    end
  end
end
