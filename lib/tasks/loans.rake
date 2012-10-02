namespace :loans do

  desc "Update expired loans to auto-cancelled/auto-removed"
  task update_expired: :environment do
    require 'loan_auto_updater'

    LoanAutoUpdater.cancel_not_progressed_loans!
    LoanAutoUpdater.cancel_not_drawn_loans!
    LoanAutoUpdater.remove_not_demanded_loans!
    LoanAutoUpdater.remove_not_closed_loans!
  end

end
