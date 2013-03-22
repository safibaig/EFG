require 'active_model/model'

class BulkLendingLimits
  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :scheme_or_phase_id, :created_by, :modified_by, :lending_limit_name,
    :ends_on, :starts_on, :guarantee_rate, :premium_rate, :allocation_type_id

  attr_accessible :scheme_or_phase_id, :lending_limit_name, :ends_on, :starts_on, :guarantee_rate,
    :premium_rate, :allocation_type_id, :lenders_attributes

  validates_presence_of :allocation_type_id, :scheme_or_phase_id, :ends_on, :guarantee_rate,
    :premium_rate, :starts_on, :lending_limit_name

  validate :ends_on_is_after_starts_on
  validates_inclusion_of :allocation_type_id, in: [LendingLimitType::Annual, LendingLimitType::Specific].map(&:id)

  def initialize(attrs = {})
    super(sanitize_for_mass_assignment(attrs))
  end

  def ends_on=(value)
    @ends_on = QuickDateFormatter.parse(value)
  end

  def starts_on=(value)
    @starts_on = QuickDateFormatter.parse(value)
  end

  def allocation_type_id=(value)
    @allocation_type_id = value.try(:to_i)
  end

  def premium_rate=(value)
    @premium_rate = value.try(:to_i)
  end

  def guarantee_rate=(value)
    @guarantee_rate = value.try(:to_i)
  end

  # Verify that a "Scheme / Phase" was selected in the validations, but if SFLG
  # was selected the phase should be nil.
  def phase
    if scheme_or_phase_id == Loan::SFLG_SCHEME
      nil
    else
      Phase.find(scheme_or_phase_id)
    end
  end

  def lenders_attributes=(values)
    values.each do |_, lender_attributes|
      lender = lenders_by_id[lender_attributes[:id].to_i]
      lender.selected = (lender_attributes[:selected] == '1')
      lender.allocation = lender_attributes[:allocation]
      lender.active = (lender_attributes[:active] == '1')
    end
  end

  def lenders
    @lenders ||= Lender.active.order_by_name.map do |lender|
      LenderLendingLimit.new(lender)
    end
  end

  def selected_lenders
    lenders.select(&:selected?)
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      selected_lenders.each do |lender_lending_limit|
        lending_limit = LendingLimit.create! do |lending_limit|
          lending_limit.name = lending_limit_name
          lending_limit.phase = phase
          lending_limit.starts_on = starts_on
          lending_limit.ends_on = ends_on
          lending_limit.guarantee_rate = guarantee_rate
          lending_limit.premium_rate = premium_rate
          lending_limit.allocation_type_id = allocation_type_id

          lending_limit.lender = lender_lending_limit.lender
          lending_limit.allocation = lender_lending_limit.allocation
          lending_limit.active = lender_lending_limit.active
        end

        AdminAudit.log(AdminAudit::LendingLimitCreated, lending_limit, created_by)
      end
    end
  end

  def valid?
    super & selected_lenders.all?(&:valid?)
  end

  private

  def lenders_by_id
    @lenders_by_id ||= lenders.index_by(&:id)
  end

  def ends_on_is_after_starts_on
    return if ends_on.nil? || starts_on.nil?
    errors.add(:ends_on, :must_be_after_starts_on) if ends_on < starts_on
  end
end
