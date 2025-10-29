module Dishwasher
  #
  # Handles deletion of selected forked repositories
  #
  module DeleteForks
    class << self
      include MessageFormatter

      #
      # Loop to delete the selected forked repos
      #
      # @param selections [Array<String>] array of repository names to delete
      #
      # @return [void] prints confirmation message when complete
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
      # @return [void] prints a title message
      #
      def confirmation_message
        title_message("Forks Deleted")
      end
    end
  end
end
