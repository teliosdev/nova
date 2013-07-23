require 'irb'

module Nova

  # Runs a shell that can be used for communication to a server or
  # multiple servers.
  #
  # @todo Add behavior.
  class Shell

    # The IRB_PROMPT that is used in the shell.
    IRB_PROMPT = {
      :AUTO_INDENT => true,
      :PROMPT_I    => "nova[%03n] >> ",
      :PROMPT_S    => "nova[%03n] %l> ",
      :PROMPT_C    => "nova[%03n] %i> ",
      :RETURN      => "nova <- %s\n"
    }

    # Starts the shell, setting up IRB so it can be used.
    #
    # @return [void]
    def start_shell
      IRB.setup __FILE__
      IRB.conf[:PROMPT][:NOVA_PROMPT] = IRB_PROMPT
      IRB.conf[:PROMPT_MODE] = :NOVA_PROMPT
      irb = IRB::Irb.new(IRB::WorkSpace.new(binding))

      IRB.conf[:MAIN_CONTEXT] = irb.context

      trap("SIGINT") { irb.signal_handle }

      begin
        catch(:IRB_EXIT) { irb.eval_input }
      ensure
        IRB.irb_at_exit
      end
    end
    
  end
end