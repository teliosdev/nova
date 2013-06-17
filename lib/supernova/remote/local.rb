require 'supernova/remote/local/platforms'
require 'supernova/remote/local/commands'
require 'supernova/remote/local/filesystem'

module Supernova
  module Remote

    # Manages the Local platform for {Star}s.
    module Local

      include Local::Platforms
      include Local::Commands
      include Local::Filesystem

      extend self
    end
  end
end
