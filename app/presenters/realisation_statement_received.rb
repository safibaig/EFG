require 'active_model/model'

class RealisationStatementReceived
  PERIOD_COVERED_QUARTERS = RealisationStatement::PERIOD_COVERED_QUARTERS

  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity
  include PresenterFormatterConcern

  attr_reader :realisation_statement
  attr_accessor :lender, :reference, :period_covered_quarter, :period_covered_year, :received_on, :creator

  attr_accessible :lender_id, :reference, :period_covered_quarter,
                  :period_covered_year, :received_on, :recoveries_to_be_realised_ids

  format :received_on, with: QuickDateFormatter

  validates :lender_id, presence: true
  validates :reference, presence: true
  validates :received_on, presence: true
  validates :period_covered_quarter, presence: true, inclusion: PERIOD_COVERED_QUARTERS
  validates :period_covered_year, presence: true, format: /\A(\d{4})\Z/
  validates_presence_of :creator, strict: true, on: :save

  validate(on: :save) do |realisation_statement|
    if realisation_statement.recoveries_to_be_realised.none?
      errors.add(:base, 'No recoveries were selected.')
    end
  end

  def self.name
    RealisationStatement.name
  end

  def lender_id
    lender && lender.id
  end

  def lender_id=(id)
    self.lender = Lender.find_by_id(id)
  end

  def recoveries
    Recovery
      .includes(:loan => :lending_limit)
      .where(loans: { lender_id: lender_id })
      .where(['recovered_on <= ?', quarter_cutoff_date])
      .where(realise_flag: false)
  end

  def grouped_recoveries
    @grouped_recoveries ||= RecoveriesGroupSet.filter(recoveries)
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

  def save
    # This is intentionally eager. We want to run all of the validations.
    return false if invalid?(:details) | invalid?(:save)

    ActiveRecord::Base.transaction do
      create_realisation_statement!
      realise_loans!
      realise_recoveries!
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private
  attr_writer :realisation_statement

  def quarter_cutoff_date
    month = {
      'March' => 3,
      'June' => 6,
      'September' => 9,
      'December' => 12
    }.fetch(period_covered_quarter)

    Date.new(period_covered_year.to_i, month).end_of_month
  end

  def create_realisation_statement!
    self.realisation_statement = RealisationStatement.create! do |realisation_statement|
      realisation_statement.lender = self.lender
      realisation_statement.reference = self.reference
      realisation_statement.period_covered_quarter = self.period_covered_quarter
      realisation_statement.period_covered_year = self.period_covered_year
      realisation_statement.received_on = self.received_on
      realisation_statement.created_by = self.creator
    end
  end

  # TODO: Don't mark loans as realised if they have futher recoveries.
  def realise_loans!
    recoveries_to_be_realised.group_by(&:loan_id).each do |loan_id, recoveries|
      realised_amount = recoveries.sum(&:amount_due_to_dti)

      self.realisation_statement.loan_realisations.create!(
        realised_loan: Loan.find(loan_id),
        created_by: creator,
        realised_amount: realised_amount,
        realised_on: Date.today
      )
    end

    loan_ids = recoveries_to_be_realised.map(&:loan_id).uniq

    Loan.where(id: loan_ids).update_all(
      modified_by_id: creator.id,
      state: Loan::Realised,
      realised_money_date: Date.today
    )
  end

  def realise_recoveries!
    ids = recoveries_to_be_realised.map(&:id)

    Recovery.where(id: ids).update_all(
      realisation_statement_id: self.realisation_statement.id,
      realise_flag: true
    )
  end
end
