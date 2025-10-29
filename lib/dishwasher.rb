require "artii"
require "octokit"
require "tty-prompt"

require "dishwasher/message_formatter"
require "dishwasher/github"
require "dishwasher/delete_forks"
require "dishwasher/version"

module Dishwasher
  class << self
    #
    # Start the Dishwasher application
    #
    # Displays ASCII art title, prompts user to select forks for deletion,
    # and deletes the selected repositories
    #
    # @return [Boolean] true when operation completes successfully
    #
    def start
      puts Artii::Base.new.asciify("Dishwasher")
      cs = Dishwasher::Github.confirmed_selections
      Dishwasher::DeleteForks.delete(cs)
      true
    end
  end
end
