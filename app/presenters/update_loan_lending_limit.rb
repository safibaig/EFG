# Allows for changing of a Loan's lending limit, if the lending limit became
# unavailable between the Loan being completed and being offered.
class UpdateLoanLendingLimit
  include LoanPresenter

  attr_reader :new_lending_limit_id, :previous_state_aid, :new_state_aid

  validates_presence_of :new_lending_limit_id

  before_save :update_lending_limit
  before_save :update_state_aid

  def available_lending_limits
    loan.lender.current_lending_limits
  end

  def new_lending_limit_id=(id)
    new_lending_limit = available_lending_limits.find_by_id(id)
    @new_lending_limit_id = new_lending_limit.try(:id)
  end

  private
  def update_lending_limit
    # We have to nil the lending_limit association otherwise the
    # :autosave_associated_records_for_lending_limit callback resets the ID back
    # to the one of the original LendingLimit object.
    loan.lending_limit = nil
    loan.lending_limit_id = new_lending_limit_id
  end

  def update_state_aid
    @previous_state_aid = loan.state_aid
    loan.recalculate_state_aid
    @new_state_aid = loan.state_aid
  end
end
