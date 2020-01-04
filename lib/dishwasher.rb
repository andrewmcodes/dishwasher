require "artii"
require "octokit"
require "tty-prompt"

require "dishwasher/message_formatter"
require "dishwasher/github"
require "dishwasher/delete_forks"
require "dishwasher/version"

module Dishwasher
  class << self
    def start
      puts Artii::Base.new.asciify("Dishwasher")
      cs = Dishwasher::Github.confirmed_selections
      Dishwasher::DeleteForks.delete(cs)
      true
    end
  end
end
