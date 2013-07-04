require 'supernova/remote/local'

describe Supernova::Remote::Local do

  before :each do
    Supernova::Star.remote = Supernova::Remote::Local
  end

  context "platforms" do

    it "should determine platforms" do
      Supernova::Star.new.platform.should have_at_least(3).items
    end
  end

  context "commands" do
    it "should execute the command" do
      star = Supernova::Star.new
      star.line("echo", "hello").pass.stdout.should eq("hello\n")
    end
  end
end
