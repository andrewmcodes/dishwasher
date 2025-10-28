require "spec_helper"

RSpec.describe Dishwasher::DeleteForks do
  describe ".delete" do
    let(:selections) { ["user/repo1", "user/repo2"] }

    before do
      allow(Dishwasher::Github).to receive(:delete_repo).and_return(true)
      allow(described_class).to receive(:puts)
    end

    it "deletes each selected repository" do
      selections.each do |repo|
        expect(Dishwasher::Github).to receive(:delete_repo).with(repo)
      end
      described_class.delete(selections)
    end

    it "prints title messages" do
      expect(described_class).to receive(:title_message).with("Deleting Forks")
      expect(described_class).to receive(:title_message).with("Forks Deleted")
      described_class.delete(selections)
    end

    it "returns after printing confirmation message" do
      result = described_class.delete(selections)
      expect(result).to be_nil
    end

    context "when selections array is empty" do
      let(:selections) { [] }

      it "does not call delete_repo" do
        expect(Dishwasher::Github).not_to receive(:delete_repo)
        described_class.delete(selections)
      end

      it "still prints messages" do
        expect(described_class).to receive(:title_message).with("Deleting Forks")
        expect(described_class).to receive(:title_message).with("Forks Deleted")
        described_class.delete(selections)
      end
    end

    context "when selections has one repository" do
      let(:selections) { ["user/single-repo"] }

      it "deletes only that repository" do
        expect(Dishwasher::Github).to receive(:delete_repo).with("user/single-repo").once
        described_class.delete(selections)
      end
    end
  end

  describe ".confirmation_message" do
    before do
      allow(described_class).to receive(:puts)
    end

    it "prints a title message" do
      expect(described_class).to receive(:title_message).with("Forks Deleted")
      described_class.confirmation_message
    end

    it "returns nil" do
      result = described_class.confirmation_message
      expect(result).to be_nil
    end
  end
end
