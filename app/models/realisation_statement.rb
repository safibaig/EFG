class RealisationStatement < ActiveRecord::Base
  include FormatterConcern

  PERIOD_COVERED_QUARTERS = ['March', 'June', 'September', 'December']

  belongs_to :lender
  belongs_to :created_by, class_name: 'User'
  has_many :loan_realisations
  has_many :realised_loans, through: :loan_realisations

  validates :lender_id, presence: true
  validates :created_by_id, presence: true, on: :create
  validates :reference, presence: true
  validates :period_covered_quarter, presence: true, inclusion: PERIOD_COVERED_QUARTERS
  validates :period_covered_year, presence: true, format: /\A(\d{4})\Z/
  validates :received_on, presence: true

  format :received_on, with: QuickDateFormatter

  attr_accessible :lender_id, :reference, :period_covered_quarter,
                  :period_covered_year, :received_on, :loans_to_be_realised_ids

  # TODO: should a field other than 'updated_at' be used here?
  def recovered_loans
    lender.loans.recovered.where(['updated_at <= ?', quarter_cutoff_time])
  end

  def loans_to_be_realised
    @loans_to_be_realised || []
  end

  def loans_to_be_realised_ids=(ids)
    @loans_to_be_realised = Loan.where(id: ids)
  end

  after_save :realise_loans
  def realise_loans
    self.class.transaction do
      raise LoanStateTransition::IncorrectLoanState unless loans_to_be_realised.all? {|loan| loan.state == Loan::Recovered }
      loans_to_be_realised.update_all(state: Loan::Realised)
      loans_to_be_realised.each do |loan|
        # TODO: persist correct realised amount in LoanRealisation
        self.loan_realisations.create!(
          realised_loan: loan,
          created_by: created_by,
          realised_amount: Money.new(0)
        )
      end
    end
  end

  private

  def quarter_cutoff_time
    day_month = case period_covered_quarter
    when 'March'
      "31/03"
    when 'June'
      "30/06"
    when 'September'
      "30/09"
    when 'December'
      "31/12"
    else
      nil
    end
    Time.parse("#{day_month}/#{period_covered_year} 23:59:59")
  end

end
