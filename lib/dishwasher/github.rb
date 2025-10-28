module Dishwasher
  #
  # Provides GitHub integration for listing and deleting forked repositories
  #
  # Supports both GitHub CLI (gh) and Octokit API for repository operations
  #
  module Github
    class << self
      include MessageFormatter

      #
      # Check if gh CLI is installed
      #
      # @return [Boolean] true if gh is installed and authenticated
      #
      def gh_cli_available?
        return @gh_cli_available unless @gh_cli_available.nil?

        @gh_cli_available = gh_version_check && gh_auth_check
      end

      #
      # Check if gh CLI is installed by running version command
      #
      # @return [Boolean] true if gh --version succeeds
      #
      def gh_version_check
        system("gh --version > /dev/null 2>&1")
      end

      #
      # Check if gh CLI is authenticated
      #
      # @return [Boolean] true if gh auth status succeeds
      #
      def gh_auth_check
        system("gh auth status > /dev/null 2>&1")
      end

      #
      # Initialize new TTY Prompt
      #
      # @return [TTY::Prompt] a new or memoized TTY::Prompt instance
      #
      def prompt
        @prompt ||= TTY::Prompt.new
      end

      #
      # Get GitHub Access Token so we can authenticate with GitHub's API
      #
      # @return [String] GitHub Access Token
      #
      def token
        @token ||= prompt.mask(title_message("What is your GitHub Personal Access Token?"), default: ENV["GITHUB_ACCESS_TOKEN"])
      end

      #
      # GitHub Client Object (only used if gh CLI is not available)
      #
      # @return [Octokit::Client] GitHub client instance
      #
      def client
        require "octokit"
        @client ||= Octokit::Client.new(access_token: token, per_page: 1000)
      end

      #
      # Delete passed in repository
      #
      # @param repo_name [String] repository name (e.g., "owner/repo")
      #
      # @return [Boolean] success or failure
      #
      def delete_repo(repo_name)
        if gh_cli_available?
          system("gh", "repo", "delete", repo_name, "--yes")
        else
          client.delete_repository(repo_name)
        end
      end

      #
      # Repositories for the authenticated user
      #
      # @return [Array] repository objects
      #
      def repos
        if gh_cli_available?
          repos_from_gh_cli
        else
          repos_from_api
        end
      end

      #
      # Get repositories using gh CLI
      #
      # @return [Array<Hash>] repository data
      # @raise [RuntimeError] if gh command fails or returns invalid JSON
      #
      def repos_from_gh_cli
        require "json"
        output = run_gh_list_repos

        begin
          JSON.parse(output, symbolize_names: true)
        rescue JSON::ParserError => e
          raise "Failed to parse GitHub CLI output: #{e.message}"
        end
      end

      #
      # Run gh CLI command to list repos
      #
      # @return [String] command output
      # @raise [RuntimeError] if command fails
      #
      def run_gh_list_repos
        output = `gh repo list --json name,nameWithOwner,isFork,owner --limit 1000`
        status = $?

        unless status && status.success?
          raise "GitHub CLI command failed. Make sure 'gh' is installed and authenticated."
        end

        output
      end

      #
      # Get repositories using Octokit API
      #
      # @return [Array] repository data
      #
      def repos_from_api
        client.repos(user: client.user, query: {type: "owner", sort: "asc"})
      end

      #
      # All forked repositories for the client
      #
      # @return [Array] all forked repositories
      #
      def forks
        if gh_cli_available?
          repos.select { |hash| hash[:isFork] == true }
        else
          repos.select { |hash| hash[:fork] == true }
        end
      end

      #
      # Potential choices to choose from for deletion
      #
      # @return [Hash] key: repo name, value: repo identifier
      #
      def choices
        if gh_cli_available?
          forks.map { |f| [f[:nameWithOwner], f[:nameWithOwner]] }.to_h
        else
          forks.map { |f| [f[:full_name], f[:full_name]] }.to_h
        end
      end

      #
      # Selected forks for deletion
      #
      # @return [Array] array of repo identifiers
      #
      def confirmed_selections
        selections = selection(choices)
        no_selections if selections.empty?
        confirmation_prompt ? selections : canceled_message
      end

      #
      # Prompt to confirm deletion of repos
      #
      # @return [Boolean] true/false depending on selection
      #
      def confirmation_prompt
        title_message("Are you sure you want to delete these forked repos?")
        prompt.yes?("→")
      end

      #
      # Array of selected identifiers
      #
      # @param c [Hash] choices hash with repo names as keys and values
      #
      # @return [Array] repo identifiers chosen for deletion
      #
      def selection(c)
        prompt.multi_select(title_message("Select forks to delete"), c)
      end

      #
      # No selection message
      #
      # @return [void] aborts the program with a message
      #
      def no_selections
        abort_message("No selections were made.")
      end

      #
      # Canceled message
      #
      # @return [void] aborts the program with a message
      #
      def canceled_message
        abort_message("Operation canceled by user.")
      end
    end
  end
end
