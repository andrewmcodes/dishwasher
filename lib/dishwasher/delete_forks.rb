require "tty-prompt"

module Dishwasher
  class DeleteForks
    attr_reader :selections, :github

    def initialize(selections: nil, github: nil)
      @selections = selections
      @github = github
    end

    #
    # Loop to delete the selected forked repos
    #
    # @return [string] confirmation_message
    #
    def delete
      Dishwasher::MessageFormatter.new(title: "Deleting Forks").title_message
      selections.each do |s|
        github.delete_repo(s)
      end
      confirmation_message
    end

    #
    # Confirmation message that the repos were removed
    #
    # @return [string] forks deleted message
    #
    def confirmation_message
      Dishwasher::MessageFormatter.new(title: "Forks Deleted").title_message
    end
  end
end
