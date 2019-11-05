require "tty-prompt"

module Dishwasher
  class Prompt
    attr_reader :prompt, :choices

    def initialize(choices: nil)
      @prompt = TTY::Prompt.new
      @choices = choices
    end

    #
    # Selected forks for deletion
    #
    # @return [array] array of repo id's
    #
    def confirmed_selections
      selection.empty? ? no_selections : selection.each { |s| Dishwasher::MessageFormatter.new(body: choices.key(s)) }

      confirmation_prompt ? selection : canceled_message
    end

    #
    # Prompt to confirm deletion of repos
    #
    # @return [boolean] T:F depending on selection
    #
    def confirmation_prompt
      prompt.yes?('Are you sure you want to delete these forked repos?')
    end

    #
    # Array of selected id's
    #
    # @return [array] repo id's chosen for deletion
    #
    def selection
      @selection ||= prompt.multi_select("Select forks to delete:", choices)
    end

    #
    # No selection message
    #
    # @return [string] message indicating no selections were made
    #
    def no_selections
      Dishwasher::MessageFormatter.new(body: "No selections were made. Operation canceled!").abort_message
    end

    #
    # Canceled message
    #
    # @return [string] message indicating the operation was canceled
    #
    def canceled_message
      Dishwasher::MessageFormatter.new(body: "Operation canceled!").abort_message
    end
  end
end
