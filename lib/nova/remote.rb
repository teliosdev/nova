module Nova
  module Remote

    autoload :Common, "nova/remote/common"
    autoload :Fake, "nova/remote/fake"
    autoload :Local, "nova/remote/local"
    autoload :SSH, "nova/remote/ssh"

  end
end
