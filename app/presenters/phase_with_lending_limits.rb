require 'active_model/model'

class PhaseWithLendingLimits
  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :name, :created_by, :modified_by, :lending_limit_name,
    :ends_on, :starts_on, :guarantee_rate, :premium_rate, :allocation_type_id

  attr_accessible :name, :lending_limit_name, :ends_on, :starts_on, :guarantee_rate,
    :premium_rate, :allocation_type_id, :lenders_attributes

  validates :name, presence: true

  def self.name
    Phase.name
  end

  def initialize(attrs = {})
    super(sanitize_for_mass_assignment(attrs))
  end

  def ends_on=(value)
    @ends_on = QuickDateFormatter.parse(value)
  end

  def starts_on=(value)
    @starts_on = QuickDateFormatter.parse(value)
  end

  def premium_rate=(value)
    @premium_rate = value.try(:to_i)
  end

  def guarantee_rate=(value)
    @guarantee_rate = value.try(:to_i)
  end

  def lenders_attributes=(values)
    values.each do |_, lender_attributes|
      lender = lenders_by_id[lender_attributes[:id].to_i]
      lender.selected = (lender_attributes[:selected] == '1')
      lender.allocation = lender_attributes[:allocation]
    end
  end

  def lenders
    @lenders ||= Lender.order_by_name.map do |lender|
      LenderLendingLimit.new(lender)
    end
  end

  def selected_lenders
    lenders.select(&:selected?)
  end

  def save
    ActiveRecord::Base.transaction do
      phase = Phase.create!(name: name) do |phase|
        phase.created_by = created_by
        phase.modified_by = created_by
      end

      AdminAudit.log(AdminAudit::PhaseCreated, phase, created_by)

      selected_lenders.each do |lender_lending_limit|
        lending_limit = LendingLimit.create! do |lending_limit|
          lending_limit.name = lending_limit_name
          lending_limit.phase = phase
          lending_limit.lender = lender_lending_limit.lender
          lending_limit.starts_on = starts_on
          lending_limit.ends_on = ends_on
          lending_limit.guarantee_rate = guarantee_rate
          lending_limit.premium_rate = premium_rate
          lending_limit.allocation_type_id = allocation_type_id
          lending_limit.allocation = lender_lending_limit.allocation
        end

        AdminAudit.log(AdminAudit::LendingLimitCreated, lending_limit, created_by)
      end
    end
  end

  private

  def lenders_by_id
    @lenders_by_id ||= lenders.index_by(&:id)
  end
end
