require 'active_model/model'

class LenderLendingLimit
  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity

  attr_reader :allocation

  attr_accessor :selected

  delegate :id, :name, :to_key, to: :lender

  def initialize(lender)
    @lender = lender
  end

  def selected?
    !!selected
  end

  def allocation=(value)
    if value.present?
      @allocation = Money.parse(value)
    else
      @allocation = nil
    end
  end

  private

  attr_reader :lender
end
