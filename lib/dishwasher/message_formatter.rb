module Dishwasher
  class MessageFormatter
    attr_reader :body, :title

    def initialize(title: nil, body: nil)
      @title = title
      @body = body
    end

    #
    # Title message formatter
    #
    # @return [string] formatted title string
    #
    def title_message
      return unless title

      puts "\n==== #{title} ====\n"
    end

    #
    # Abort message formatter
    #
    # @return [string] formatted abort string
    #
    def abort_message
      return unless body

      abort "\n==== #{body} ====\n"
    end

    #
    # Body message formatter
    #
    # @return [string] formatted body string
    #
    def body_message
      return unless body

      puts "\n#{body}\n"
    end
  end
end
