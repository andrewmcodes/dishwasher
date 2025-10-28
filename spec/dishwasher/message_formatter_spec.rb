require "spec_helper"

RSpec.describe Dishwasher::MessageFormatter do
  # Create a test class that includes the module
  let(:test_class) do
    Class.new do
      include Dishwasher::MessageFormatter
    end
  end

  let(:instance) { test_class.new }

  describe "#title_message" do
    it "prints a formatted title message" do
      expect { instance.title_message("Test Message") }.to output("\n==== Test Message ====\n").to_stdout
    end

    it "returns nil" do
      result = nil
      expect { result = instance.title_message("Test") }.to output.to_stdout
      expect(result).to be_nil
    end
  end

  describe "#abort_message" do
    it "aborts with a formatted message" do
      expect { instance.abort_message("Error occurred") }.to raise_error(SystemExit)
        .and output("\n==== Error occurred ====\n").to_stderr
    end
  end

  describe "#body_message" do
    it "prints a formatted body message" do
      expect { instance.body_message("Body content") }.to output("\nBody content\n").to_stdout
    end

    it "returns nil" do
      result = nil
      expect { result = instance.body_message("Content") }.to output.to_stdout
      expect(result).to be_nil
    end
  end
end
