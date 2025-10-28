module Dishwasher
  module DeleteForks
    class << self
      include MessageFormatter

      #
      # Loop to delete the selected forked repos
      #
      # @return [string] confirmation_message
      #
      def delete(selections)
        title_message("Deleting Forks")
        selections.each do |s|
          Dishwasher::Github.delete_repo(s)
        end
        confirmation_message
      end

      #
      # Confirmation message that the repos were removed
      #
      # @return [string] forks deleted message
      #
      def confirmation_message
        title_message("Forks Deleted")
      end
    end
  end
end
