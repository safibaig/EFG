class AgreedDraw
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Validations

  attr_reader :amount_drawn, :date_of_change, :loan
  attr_accessor :created_by
  attr_accessible :amount_drawn, :date_of_change

  validates_presence_of :created_by, strict: true
  validates_presence_of :date_of_change
  validate :validate_amount_drawn

  def initialize(loan)
    @loan = loan
  end

  def amount_drawn=(value)
    @amount_drawn = value.present? ? Money.parse(value) : nil
  end

  def attributes=(attributes)
    sanitize_for_mass_assignment(attributes).each do |k, v|
      public_send("#{k}=", v)
    end
  end

  def date_of_change=(value)
    @date_of_change = value.present? ? QuickDateFormatter.parse(value) : nil
  end

  def persisted?
    false
  end

  def save
    return false if invalid?

    loan.transaction do
      loan_change.amount_drawn = amount_drawn
      loan_change.change_type_id = ChangeType::RecordAgreedDraw.id
      loan_change.created_by = created_by
      loan_change.date_of_change = date_of_change
      loan_change.modified_date = Date.current
      loan_change.save!

      loan.last_modified_at = Time.now
      loan.modified_by = created_by
      loan.save!
    end
  end

  private
    def loan_change
      @loan_change ||= loan.loan_changes.new
    end

    def validate_amount_drawn
      if amount_drawn.nil?
        errors.add(:amount_drawn, :required)
      elsif amount_drawn <= 0
        errors.add(:amount_drawn, :must_be_positive)
      elsif amount_drawn > loan.amount_not_yet_drawn
        errors.add(:amount_drawn, :exceeds_amount_available)
      end
    end
end
