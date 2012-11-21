require 'loan_auto_updater'

ActiveRecord::Base.transaction do
  live_date = Date.new(2012, 10, 20)

  state = Loan::AutoRemoved
  event = LoanEvent::NotClosed
  changes = LoanStateChange.where(state: state).where(event_id: event.id).where('modified_at >= ?', live_date).includes(:loan)

  puts "#{event.name} (#{changes.count})"
  progress_bar = ProgressBar.new('', changes.count)

  changes.find_each do |change|
    loan = change.loan

    changes = loan.state_changes
    raise RuntimeError, 'not enough changes' unless changes.size >= 2
    raise RuntimeError, 'not latest change' unless changes.last == change

    previous_change = changes[-2]
    loan.update_attribute(:state, previous_change.state)
    change.delete

    progress_bar.inc
  end

  progress_bar.finish
  puts

  LoanAutoUpdater.remove_not_closed_loans!
end
