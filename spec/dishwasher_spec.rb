require "spec_helper"

RSpec.describe Dishwasher do
  it "has a version number" do
    expect(Dishwasher::VERSION).not_to be_nil
  end

  describe ".start" do
    let(:artii_double) { instance_double(Artii::Base) }
    let(:confirmed_selections) { ["user/repo1", "user/repo2"] }

    before do
      allow(Artii::Base).to receive(:new).and_return(artii_double)
      allow(artii_double).to receive(:asciify).with("Dishwasher").and_return("ASCII Art")
      allow(Dishwasher::Github).to receive(:confirmed_selections).and_return(confirmed_selections)
      allow(Dishwasher::DeleteForks).to receive(:delete)
      allow(described_class).to receive(:puts)
    end

    it "prints ASCII art" do
      expect(described_class).to receive(:puts).with("ASCII Art")
      described_class.start
    end

    it "gets confirmed selections from Github module" do
      expect(Dishwasher::Github).to receive(:confirmed_selections)
      described_class.start
    end

    it "deletes the confirmed selections" do
      expect(Dishwasher::DeleteForks).to receive(:delete).with(confirmed_selections)
      described_class.start
    end

    it "returns true" do
      expect(described_class.start).to be true
    end
  end
end
