class RealisationStatement < ActiveRecord::Base
  include FormatterConcern

  PERIOD_COVERED_QUARTERS = ['March', 'June', 'September', 'December']

  belongs_to :lender
  belongs_to :created_by, class_name: 'User'
  has_many :loan_realisations
  has_many :realised_loans, through: :loan_realisations
  has_many :recoveries

  validates :lender_id, presence: true
  validates :created_by_id, presence: true, on: :create
  validates :reference, presence: true
  validates :period_covered_quarter, presence: true, inclusion: PERIOD_COVERED_QUARTERS
  validates :period_covered_year, presence: true, format: /\A(\d{4})\Z/
  validates :received_on, presence: true
  validate(on: :create) do |realisation_statement|
    if realisation_statement.recoveries_to_be_realised.none?
      errors.add(:base, 'No recoveries were selected.')
    end
  end

  format :received_on, with: QuickDateFormatter

  attr_accessible :lender_id, :reference, :period_covered_quarter,
                  :period_covered_year, :received_on, :recoveries_to_be_realised_ids

  def recoveries
    Recovery
      .includes(:loan)
      .where(loans: { lender_id: lender_id })
      .where(['recovered_on <= ?', quarter_cutoff_date])
      .where(realise_flag: false)
  end

  def recoveries_to_be_realised
    @recoveries_to_be_realised || Recovery.none
  end

  def recoveries_to_be_realised_ids=(ids)
    @recoveries_to_be_realised = begin
      Recovery
        .joins(:loan)
        .where(loans: { lender_id: lender_id })
        .where(id: ids)
        .where(realise_flag: false)
    end
  end

  def save_and_realise_loans
    transaction do
      save!
      realise_loans!
      realise_recoveries!
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def quarter_cutoff_date
    month = {
      'March' => 3,
      'June' => 6,
      'September' => 9,
      'December' => 12
    }.fetch(period_covered_quarter)

    Date.new(period_covered_year.to_i, month).end_of_month
  end

  # TODO: Don't mark loans as realised if they have futher recoveries.
  def realise_loans!
    recoveries_to_be_realised.group_by(&:loan_id).each do |loan_id, recoveries|
      realised_amount = recoveries.sum(&:realisations_due_to_gov)

      self.loan_realisations.create!(
        realised_loan: Loan.find(loan_id),
        created_by: created_by,
        realised_amount: realised_amount
      )
    end

    loan_ids = recoveries_to_be_realised.map(&:loan_id).uniq

    Loan.where(id: loan_ids).update_all(state: Loan::Realised)
  end

  def realise_recoveries!
    ids = recoveries_to_be_realised.map(&:id)

    Recovery.where(id: ids).update_all(
      realisation_statement_id: id,
      realise_flag: true
    )
  end
end
