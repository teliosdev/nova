describe Supernova::Starbound::Encryptor do

  it "has the correct number of encryptors" do
    described_class.encryptors.should have(3).items
  end

  it "all responds to a normal api" do
    described_class.encryptors.each do |enc|
      sub = enc.new

      [:encrypt, :decrypt, :private_key!, :public_key,
        :other_public_key].each do |m|
        sub.respond_to?(m)
      end
    end
  end
end
