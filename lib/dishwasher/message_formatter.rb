module Dishwasher
  #
  # Provides message formatting utilities for consistent output
  #
  module MessageFormatter
    #
    # Title message formatter
    #
    # @param message [String] the message to format
    #
    # @return [void] prints the formatted title string
    #
    def title_message(message)
      puts "\n==== #{message} ====\n"
    end

    #
    # Abort message formatter
    #
    # @param message [String] the message to format
    #
    # @return [void] aborts the program with the formatted string
    #
    def abort_message(message)
      abort "\n==== #{message} ====\n"
    end

    #
    # Body message formatter
    #
    # @param message [String] the message to format
    #
    # @return [void] prints the formatted body string
    #
    def body_message(message)
      puts "\n#{message}\n"
    end
  end
end
