require_relative 'star/some_type'

describe Nova::Star do

  before :each do
    Nova::Star.remote = Nova::Remote::Fake
  end

  context "management" do
    it "handles types" do
      expect(Nova::Star.types).to eq(star: Nova::Star, some_type: SomeType)
    end

    it "has pretty inspect" do
      expect(Nova::Star.inspect).to eq("Nova::Star")
      expect(SomeType.inspect).to eq("Nova::Star/SomeType")
    end

    it "has a default remote" do
      expect(SomeType.remote).to be(Nova::Remote::Fake)
    end
  end

  context "options manager" do
    it "validates options" do
      expect {
        star = SomeType.new
        star.options = {}
      }.to raise_error(Nova::InvalidOptionsError)
    end
  end

  context "event manager" do
    it "manages events" do
      event = Nova::Common::EventHandler::Event
      [SomeType, SomeType.new].each do |type|
        expect(type.events).to be_instance_of Set
        expect(type.has_event?(:foo)).to be_instance_of event
        expect(type.has_event?(:not_foo)).to be_nil
        expect(type.has_event?(:bar)).to be_instance_of event

        expect(type.has_event_with_options?(:foo)).to be_instance_of event
        expect(type.has_event_with_options?(:bar)).to be_nil
        expect(type.has_event_with_options?(:bar, an_option: true)).to be_instance_of event
      end
    end

    it "runs events" do
      star = SomeType.new
      context = double(:context)
      star.bind! context

      expect(star.run!(:foo)).to be 1

      expect {
        star.run!(:bar)
      }.to raise_error(Nova::NoEventError)
      expect(star.run(:bar)).to be_instance_of Nova::NoEventError
      expect(star.run!(:bar, an_option: true)).to be 2

      expect {
        star.run! :not_an_event
      }.to raise_error(Nova::NoEventError)
      expect(star.run(:not_an_event)).to be_instance_of Nova::NoEventError
    end
  end

  context "features" do
    it "supports defined features" do
      expect(SomeType.supports?(:some_feature)).to be true
      expect(SomeType.supports?(:another_feature)).to be false
    end

    it "gives fake features" do
      star = SomeType.new
      expect(star.feature(:some_feature)).to_not be_fake
      expect(star.feature(:another_feature)).to be_fake

      expect(star.supports?(:some_feature)).to be true
      expect(star.supports?(:another_feature)).to be false
    end

    it "runs enable and disable events" do
      star = SomeType.new
      context = double(:context)
      context.should_receive(:tag).with(:enable)
      expect(star.feature(:some_feature).bind(context).enable!).to be 3

      context = double(:context)
      context.should_receive(:tag).with(:disable)
      expect(star.feature(:some_feature).bind(context).disable!).to be 4
    end
  end

  context "platforms" do
    it "displays correct platforms" do
      expect(SomeType.new.remote.platform.types).to eq([])
    end
  end

  context "commands" do
    it "gives a command line" do
      star = SomeType.new
      expect(star.remote.command.line("something", "arguments")).to be_instance_of Command::Runner
    end
  end
end
