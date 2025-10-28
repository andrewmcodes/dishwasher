require "spec_helper"

RSpec.describe Dishwasher::Github do
  let(:prompt_double) { instance_double(TTY::Prompt) }

  before do
    # Reset all instance variables before each test
    described_class.instance_variable_set(:@gh_cli_available, nil)
    described_class.instance_variable_set(:@prompt, nil)
    described_class.instance_variable_set(:@token, nil)
    described_class.instance_variable_set(:@client, nil)

    allow(TTY::Prompt).to receive(:new).and_return(prompt_double)
  end

  describe ".gh_cli_available?" do
    before do
      # Reset for each test in this describe block
      described_class.instance_variable_set(:@gh_cli_available, nil)
    end

    context "when gh CLI is installed and authenticated" do
      it "returns true when both checks succeed" do
        allow(described_class).to receive(:gh_version_check).and_return(true)
        allow(described_class).to receive(:gh_auth_check).and_return(true)

        expect(described_class.gh_cli_available?).to be true
      end
    end

    context "when gh CLI is not installed" do
      it "returns false when version check fails" do
        allow(described_class).to receive(:gh_version_check).and_return(false)
        allow(described_class).to receive(:gh_auth_check).and_return(false)

        expect(described_class.gh_cli_available?).to be false
      end
    end

    context "when gh CLI is installed but not authenticated" do
      it "returns false when auth check fails" do
        allow(described_class).to receive(:gh_version_check).and_return(true)
        allow(described_class).to receive(:gh_auth_check).and_return(false)

        expect(described_class.gh_cli_available?).to be false
      end
    end

    context "when called multiple times" do
      it "caches the result" do
        call_count = 0
        allow(described_class).to receive(:gh_version_check) do
          call_count += 1
          true
        end
        allow(described_class).to receive(:gh_auth_check).and_return(true)

        first_call = described_class.gh_cli_available?
        second_call = described_class.gh_cli_available?

        expect(first_call).to eq(second_call)
        expect(call_count).to eq(1) # Should only be called once due to caching
      end
    end
  end

  describe ".prompt" do
    it "returns a TTY::Prompt instance" do
      expect(described_class.prompt).to eq(prompt_double)
    end

    it "memoizes the prompt instance" do
      first = described_class.prompt
      second = described_class.prompt
      expect(first).to equal(second)
    end
  end

  describe ".token" do
    before do
      allow(described_class).to receive(:puts) # Suppress title_message output
      allow(prompt_double).to receive(:mask).and_return("test_token_123")
    end

    it "prompts for a GitHub token" do
      expect(prompt_double).to receive(:mask).with(
        nil,
        default: ENV["GITHUB_ACCESS_TOKEN"]
      )
      described_class.token
    end

    it "returns the token" do
      expect(described_class.token).to eq("test_token_123")
    end

    it "memoizes the token" do
      first = described_class.token
      second = described_class.token
      expect(first).to equal(second)
    end

    context "when GITHUB_ACCESS_TOKEN env var is set" do
      before do
        ENV["GITHUB_ACCESS_TOKEN"] = "env_token"
      end

      after do
        ENV.delete("GITHUB_ACCESS_TOKEN")
      end

      it "uses it as the default" do
        expect(prompt_double).to receive(:mask).with(nil, default: "env_token")
        described_class.token
      end
    end
  end

  describe ".repos" do
    context "when gh CLI is available" do
      before do
        allow(described_class).to receive(:gh_cli_available?).and_return(true)
        allow(described_class).to receive(:repos_from_gh_cli).and_return([{name: "repo1"}])
      end

      it "uses repos_from_gh_cli" do
        expect(described_class).to receive(:repos_from_gh_cli)
        described_class.repos
      end

      it "returns the repos from gh CLI" do
        expect(described_class.repos).to eq([{name: "repo1"}])
      end
    end

    context "when gh CLI is not available" do
      before do
        allow(described_class).to receive(:gh_cli_available?).and_return(false)
        allow(described_class).to receive(:repos_from_api).and_return([{name: "repo2"}])
      end

      it "uses repos_from_api" do
        expect(described_class).to receive(:repos_from_api)
        described_class.repos
      end

      it "returns the repos from API" do
        expect(described_class.repos).to eq([{name: "repo2"}])
      end
    end
  end

  describe ".repos_from_gh_cli" do
    let(:gh_output) do
      [
        {name: "repo1", nameWithOwner: "user/repo1", isFork: false, owner: {login: "user"}},
        {name: "repo2", nameWithOwner: "user/repo2", isFork: true, owner: {login: "user"}}
      ].to_json
    end

    before do
      allow(described_class).to receive(:run_gh_list_repos).and_return(gh_output)
    end

    it "calls run_gh_list_repos to get data" do
      expect(described_class).to receive(:run_gh_list_repos)
      described_class.repos_from_gh_cli
    end

    it "parses and returns JSON with symbolized names" do
      result = described_class.repos_from_gh_cli
      expect(result).to be_an(Array)
      expect(result.first).to have_key(:name)
      expect(result.first).to have_key(:nameWithOwner)
      expect(result.first).to have_key(:isFork)
    end

    context "when JSON parsing fails" do
      before do
        allow(described_class).to receive(:run_gh_list_repos).and_return("invalid json")
      end

      it "raises an error with helpful message" do
        expect { described_class.repos_from_gh_cli }.to raise_error(
          RuntimeError,
          /Failed to parse GitHub CLI output/
        )
      end
    end
  end

  describe ".repos_from_api" do
    let(:client_double) { instance_double(Octokit::Client) }
    let(:user_double) { double(login: "testuser") }

    before do
      allow(described_class).to receive(:client).and_return(client_double)
      allow(client_double).to receive(:user).and_return(user_double)
      allow(client_double).to receive(:repos).and_return([{name: "repo1"}])
    end

    it "fetches repos from Octokit client" do
      expect(client_double).to receive(:repos).with(user: user_double, query: {type: "owner", sort: "asc"})
      described_class.repos_from_api
    end

    it "returns the repos" do
      expect(described_class.repos_from_api).to eq([{name: "repo1"}])
    end
  end

  describe ".forks" do
    context "when using gh CLI" do
      let(:repos) do
        [
          {name: "repo1", isFork: false},
          {name: "repo2", isFork: true},
          {name: "repo3", isFork: true}
        ]
      end

      before do
        allow(described_class).to receive(:gh_cli_available?).and_return(true)
        allow(described_class).to receive(:repos).and_return(repos)
      end

      it "filters repos where isFork is true" do
        result = described_class.forks
        expect(result.length).to eq(2)
        expect(result.all? { |r| r[:isFork] == true }).to be true
      end
    end

    context "when using API" do
      let(:repos) do
        [
          {name: "repo1", fork: false},
          {name: "repo2", fork: true},
          {name: "repo3", fork: true}
        ]
      end

      before do
        allow(described_class).to receive(:gh_cli_available?).and_return(false)
        allow(described_class).to receive(:repos).and_return(repos)
      end

      it "filters repos where fork is true" do
        result = described_class.forks
        expect(result.length).to eq(2)
        expect(result.all? { |r| r[:fork] == true }).to be true
      end
    end
  end

  describe ".choices" do
    context "when using gh CLI" do
      let(:forks) do
        [
          {nameWithOwner: "user/fork1"},
          {nameWithOwner: "user/fork2"}
        ]
      end

      before do
        allow(described_class).to receive(:gh_cli_available?).and_return(true)
        allow(described_class).to receive(:forks).and_return(forks)
      end

      it "returns a hash with nameWithOwner as keys and values" do
        result = described_class.choices
        expect(result).to eq({
          "user/fork1" => "user/fork1",
          "user/fork2" => "user/fork2"
        })
      end
    end

    context "when using API" do
      let(:forks) do
        [
          {full_name: "user/fork1"},
          {full_name: "user/fork2"}
        ]
      end

      before do
        allow(described_class).to receive(:gh_cli_available?).and_return(false)
        allow(described_class).to receive(:forks).and_return(forks)
      end

      it "returns a hash with full_name as keys and values" do
        result = described_class.choices
        expect(result).to eq({
          "user/fork1" => "user/fork1",
          "user/fork2" => "user/fork2"
        })
      end
    end
  end

  describe ".delete_repo" do
    context "when gh CLI is available" do
      before do
        allow(described_class).to receive(:gh_cli_available?).and_return(true)
        allow(described_class).to receive(:system).and_return(true)
      end

      it "deletes the repo using gh CLI with proper argument separation" do
        expect(described_class).to receive(:system).with("gh", "repo", "delete", "user/repo", "--yes")
        described_class.delete_repo("user/repo")
      end

      it "returns the result of the system call" do
        expect(described_class.delete_repo("user/repo")).to be true
      end
    end

    context "when gh CLI is not available" do
      let(:client_double) { instance_double(Octokit::Client) }

      before do
        allow(described_class).to receive(:gh_cli_available?).and_return(false)
        allow(described_class).to receive(:client).and_return(client_double)
        allow(client_double).to receive(:delete_repository).and_return(true)
      end

      it "deletes the repo using Octokit" do
        expect(client_double).to receive(:delete_repository).with("user/repo")
        described_class.delete_repo("user/repo")
      end

      it "returns the result of the API call" do
        expect(described_class.delete_repo("user/repo")).to be true
      end
    end
  end

  describe ".selection" do
    let(:choices) { {"repo1" => "id1", "repo2" => "id2"} }

    before do
      allow(described_class).to receive(:puts) # Suppress title_message output
      allow(prompt_double).to receive(:multi_select).and_return(["id1"])
    end

    it "prompts for multi-selection" do
      expect(prompt_double).to receive(:multi_select).with(nil, choices)
      described_class.selection(choices)
    end

    it "returns the selected choices" do
      expect(described_class.selection(choices)).to eq(["id1"])
    end
  end

  describe ".confirmation_prompt" do
    before do
      allow(described_class).to receive(:puts) # Suppress title_message output
      allow(prompt_double).to receive(:yes?).and_return(true)
    end

    it "prompts for yes/no confirmation" do
      expect(prompt_double).to receive(:yes?).with("→")
      described_class.confirmation_prompt
    end

    it "returns the user's response" do
      expect(described_class.confirmation_prompt).to be true
    end
  end

  describe ".confirmed_selections" do
    let(:choices) { {"repo1" => "id1"} }

    before do
      allow(described_class).to receive(:puts) # Suppress output
      allow(described_class).to receive(:choices).and_return(choices)
      allow(described_class).to receive(:selection).and_return(["id1"])
      allow(described_class).to receive(:confirmation_prompt).and_return(true)
    end

    context "when selections are made and confirmed" do
      it "returns the selections" do
        expect(described_class.confirmed_selections).to eq(["id1"])
      end
    end

    context "when no selections are made" do
      before do
        allow(described_class).to receive(:selection).and_return([])
      end

      it "calls no_selections" do
        expect(described_class).to receive(:no_selections)
        described_class.confirmed_selections
      end
    end

    context "when selections are made but not confirmed" do
      before do
        allow(described_class).to receive(:confirmation_prompt).and_return(false)
      end

      it "calls canceled_message" do
        expect(described_class).to receive(:canceled_message)
        described_class.confirmed_selections
      end
    end
  end

  describe ".no_selections" do
    it "aborts with a message" do
      expect { described_class.no_selections }.to raise_error(SystemExit)
    end
  end

  describe ".canceled_message" do
    it "aborts with a message" do
      expect { described_class.canceled_message }.to raise_error(SystemExit)
    end
  end
end
