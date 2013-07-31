module Nova

  # The networking module of Nova.  It's meant to be fast,
  # secure, and cross-platform compatible.
  module Starbound

    autoload :Protocol, "nova/starbound/protocol"
    autoload :Encryptor, "nova/starbound/encryptor"
    autoload :Encryptors, "nova/starbound/encryptors"
    autoload :Client, "nova/starbound/client"
    autoload :Server, "nova/starbound/server"
    autoload :Cluster, "nova/starbound/cluster"

  end
end
