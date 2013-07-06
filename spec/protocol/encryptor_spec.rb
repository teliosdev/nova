describe Supernova::Starbound::Encryptor do

  it "is not available" do
    described_class.should_not be_available

    expect {
      subject
    }.to raise_error NotImplementedError
  end

  context "encrypting" do
    before(:each) { described_class.stub(:available?).and_return(true) }

    it "raises errors" do
      [:encrypt, :decrypt, :private_key!, :public_key,
        :other_public_key=].each do |m|

        expect { subject.send(m) }.to raise_error NotImplementedError
      end
    end
  end
end
