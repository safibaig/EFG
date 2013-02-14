require 'active_model/model'

class PhaseWithLendingLimits
  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity

  attr_writer :lenders_attributes

  attr_accessor :name, :created_by, :updated_by, :modified_by, :lending_limit_name,
    :ends_on, :starts_on, :guarantee_rate, :premium_rate, :allocation_type_id

  validates :name, presence: true

  def lenders
    Lender.order_by_name.map do |lender|
      LenderLendingLimit.new(lender)
    end
  end
end
