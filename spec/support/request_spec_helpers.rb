module RequestSpecHelpers

  def should_log_loan_state_change(loan, to_state, event_id, user)
    loan.state_changes.count.should == 1
    state_change = loan.state_changes.last
    state_change.state.should == to_state
    state_change.event.should == LoanEvent.find(event_id)
    state_change.modified_by.should == user
  end

end

RSpec.configure do |config|
  config.include RequestSpecHelpers, type: :request
end
