describe Supernova::Constructor do

  it "should create stars from types" do
    d = described_class.new(non_existant_star: :some_name) {}

    expect {
      d.modify_or_create
    }.to raise_error(Supernova::NoStarError)

    d = described_class.new(star: :some_name) do
      def some_method; 5; end
    end

    klass = d.modify_or_create
    expect(klass.as).to be :some_name
    expect(klass.instance_methods).to include(:some_method)
    expect(klass.new.some_method).to be 5
  end

end
