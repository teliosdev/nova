describe Supernova::Starbound::Encryptor do

  it "is not available" do
    described_class.should_not be_available

    expect {
      subject
    }.to raise_error NotImplementedError
  end

  it "is not plaintext" do
    described_class.should_not be_plaintext
  end

  it "sorts the encryptors" do
    described_class.sorted_encryptors.should have(3).items
    described_class.sorted_encryptors.first.preference.should > described_class.sorted_encryptors.last.preference
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
