require "octokit"

module Dishwasher
  class Github
    attr_reader :token

    def initialize
      @token = ENV['GITHUB_TOKEN'] || ARGV[0]
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
      client.repos(user: client.user, query: {type: 'owner', sort: 'asc'})
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
      forks.map{ |f| [f[:full_name], f[:id]] }.to_h
    end
  end
end
