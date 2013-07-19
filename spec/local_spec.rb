=begin

require 'nova/remote/local'

describe Nova::Remote::Local do

  before :each do
    Nova::Star.remote = Nova::Remote::Local
  end

  context "platforms" do

    it "should determine platforms" do
      expect(Nova::Star.new.platform).to have_at_least(3).items
    end
  end

  context "commands" do
    it "should execute the command" do
      star = Nova::Star.new
      expect(star.line("echo", "hello").pass.stdout).to eq("hello\n")
    end
  end
end

=end