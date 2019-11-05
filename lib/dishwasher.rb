require "dishwasher/version"
require "dishwasher/prompt"
require "dishwasher/github"
require "dishwasher/delete_forks"
require "dishwasher/message_formatter"

module Dishwasher
  class Error < StandardError; end

  gh = Dishwasher::Github.new
  choices = gh.choices
  cs = Dishwasher::Prompt.new(choices: choices).confirmed_selections
  Dishwasher::DeleteForks.new(selections: cs, github: gh).delete
end
