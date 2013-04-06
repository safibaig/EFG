class LoanSatisfyLenderDemand
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::LenderDemand], to: Loan::Guaranteed, event: LoanEvent::ChangeAmountOrTerms

  attr_reader :date_of_change

  after_save :create_loan_change

  validates_presence_of :date_of_change

  def date_of_change=(value)
    @date_of_change = value.present? ? QuickDateFormatter.parse(value) : nil
  end

  private
    def create_loan_change
      loan_change = loan.loan_changes.new
      loan_change.change_type = ChangeType::LenderDemandSatisfied
      loan_change.created_by = modified_by
      loan_change.date_of_change = date_of_change
      loan_change.modified_date = Date.current
      loan_change.save!
    end
end
