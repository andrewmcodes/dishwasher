module Dishwasher
  module Github
    class << self
      include MessageFormatter
      #
      # Initialize new TTY Prompt
      #
      # @return [object] TTY::Prompt
      #
      def prompt
        @prompt ||= TTY::Prompt.new
      end

      #
      # Get GitHub Access Token so we can authenticate with GitHub's API
      #
      # @return [string] GitHub Access Token
      #
      def token
        @token ||= prompt.mask(title_message("What is your GitHub Personal Access Token?"), default: ENV["GITHUB_ACCESS_TOKEN"])
      end

      #
      # GitHub Client Object
      #
      # @return [object] GitHub Client Object
      #
      def client
        @client ||= Octokit::Client.new(access_token: token, per_page: 1000)
      end

      #
      # Delete passed in repository ID
      #
      # @param [int] r repository ID
      #
      # @return [Boolean] success or failure
      #
      def delete_repo(r)
        client.delete_repository(r)
      end

      #
      # Repositories for the client object
      #
      # @return [object] repository objects
      #
      def repos
        client.repos(user: client.user, query: {type: "owner", sort: "asc"})
      end

      #
      # All forked repositories for the client
      #
      # @return [object] all forked repositories for the client
      #
      def forks
        repos.select { |hash| hash[:fork] == true }
      end

      #
      # Potential choices to choose from for deletion
      #
      # @return [hash] key: repo name, value: repo id
      #
      def choices
        forks.map { |f| [f[:full_name], f[:id]] }.to_h
      end

      #
      # Selected forks for deletion
      #
      # @return [array] array of repo id's
      #
      def confirmed_selections
        selections = selection(choices)
        no_selections if selections.empty?
        confirmation_prompt ? selections : canceled_message
      end

      #
      # Prompt to confirm deletion of repos
      #
      # @return [boolean] T:F depending on selection
      #
      def confirmation_prompt
        title_message("Are you sure you want to delete these forked repos?")
        prompt.yes?("→")
      end

      #
      # Array of selected id's
      #
      # @return [array] repo id's chosen for deletion
      #
      def selection(c)
        prompt.multi_select(title_message("Select forks to delete"), c)
      end

      #
      # No selection message
      #
      # @return [string] message indicating no selections were made
      #
      def no_selections
        abort_message("No selections were made.")
      end

      #
      # Canceled message
      #
      # @return [string] message indicating the operation was canceled
      #
      def canceled_message
        abort_message("Operation canceled by user.")
      end
    end
  end
end
