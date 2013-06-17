describe Supernova::Constructor do

  it "should create stars from types" do
    d = described_class.new(non_existant_star: :some_name) {}

    expect {
      d.create
    }.to raise_error(Supernova::NoStarError)

    d = described_class.new(star: :some_name) do
      def some_method; 5; end
    end

    klass = d.create
    klass.as.should be :some_name
    klass.instance_methods.should include(:some_method)
    klass.new.some_method.should be 5
  end

end
