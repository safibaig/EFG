require 'active_model/model'

class LoanChangePresenter
  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity
  extend  ActiveModel::Callbacks

  def self.model_name
    ActiveModel::Name.new(self, nil, 'LoanChange')
  end

  define_model_callbacks :save

  before_save :update_loan_change
  before_save :update_loan

  attr_accessor :created_by, :loan
  attr_reader :date_of_change
  attr_accessible :date_of_change

  validates :date_of_change, presence: true
  validates :loan, presence: true, strict: true
  validates :created_by, presence: true, strict: true

  def initialize(attributes = {})
    super(sanitize_for_mass_assignment(attributes))
  end

  def date_of_change=(value)
    @date_of_change = QuickDateFormatter.parse(value)
  end

  def loan_change
    @loan_change ||= loan.loan_changes.new
  end

  def save
    return false unless valid?

    loan.transaction do
      run_callbacks :save do
        loan_change.created_by = created_by
        loan_change.date_of_change = date_of_change
        loan_change.modified_date = Date.current
        loan_change.save!

        loan.last_modified_at = Time.now
        loan.modified_by = created_by
        loan.save!
      end
    end

    true
  end

  private
    def update_loan
    end

    def update_loan_change
    end
end
