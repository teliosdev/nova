require_relative 'star/some_type'

describe Supernova::Star do

  before :each do
    Supernova::Star.remote = Supernova::Remote::Fake
  end

  context "management" do
    it "handles types" do
      Supernova::Star.types.should eq(star: Supernova::Star, some_type: SomeType)
    end

    it "has pretty inspect" do
      Supernova::Star.inspect.should eq("Supernova::Star")
      SomeType.inspect.should eq("Supernova::Star/SomeType")
    end

    it "has a default remote" do
      SomeType.remote.should be(Supernova::Remote::Fake)
    end

    it "forwards methods to the remote" do
      star = SomeType.new
      star.remote = stub(:remote)
      star.remote.should_receive(:respond_to?).with(:some_missing_method, false).and_return(true)
      star.remote.should_receive(:some_missing_method).and_return(32)
      star.respond_to?(:some_missing_method).should be true
      star.remote.some_missing_method.should be 32
    end
  end

  context "options manager" do
    it "validates options" do
      expect {
        star = SomeType.new
        star.options = {}
      }.to raise_error(Supernova::InvalidOptionsError)
    end

    it "returns an Options instance" do
      star = SomeType.new

      star.options = { hello: :world }
      star.options.should be_instance_of Supernova::Remote::Common::OptionsManager::Options
    end
  end

  context "event manager" do
    it "manages events" do
      event = Supernova::Remote::Common::EventHandler::Event
      [SomeType, SomeType.new].each do |type|
        type.events.should be_instance_of Set
        type.has_event?(:foo).should be_instance_of event
        type.has_event?(:not_foo).should be_nil
        type.has_event?(:bar).should be_instance_of event

        type.has_event_with_options?(:foo).should be_instance_of event
        type.has_event_with_options?(:bar).should be_nil
        type.has_event_with_options?(:bar, an_option: true).should be_instance_of event
      end
    end

    it "runs events" do
      star = SomeType.new
      context = double(:context)
      star.bind! context

      star.run!(:foo).should be 1

      expect {
        star.run!(:bar)
      }.to raise_error(Supernova::NoEventError)
      star.run(:bar).should be_instance_of Supernova::NoEventError
      star.run!(:bar, an_option: true).should be 2

      expect {
        star.run! :not_an_event
      }.to raise_error(Supernova::NoEventError)
      star.run(:not_an_event).should be_instance_of Supernova::NoEventError
    end
  end

  context "features" do
    it "supports defined features" do
      SomeType.supports?(:some_feature).should be true
      SomeType.supports?(:another_feature).should be false
    end

    it "gives fake features" do
      star = SomeType.new
      star.feature(:some_feature).should_not be_fake
      star.feature(:another_feature).should be_fake

      star.supports?(:some_feature).should be true
      star.supports?(:another_feature).should be false
    end

    it "runs enable and disable events" do
      star = SomeType.new
      context = stub(:context)
      context.should_receive(:tag).with(:enable)
      star.feature(:some_feature).bind(context).enable!.should be 3

      context = stub(:context)
      context.should_receive(:tag).with(:disable)
      star.feature(:some_feature).bind(context).disable!.should be 4
    end
  end

  context "platforms" do
    it "displays correct platforms" do
      SomeType.new.platform.should eq([])
    end
  end

  context "commands" do
    it "gives a command line" do
      star = SomeType.new
      star.line("something", "arguments").should be_instance_of Cocaine::CommandLine
      star.line("something", "arguments").instance_variable_get(:@logger).should be Supernova.logger
    end
  end
end
