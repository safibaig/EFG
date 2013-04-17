# encoding: utf-8

class RealiseRecovery
  include ActiveModel::Model

  def initialize(recovery)
    @recovery = recovery
  end

  attr_reader :recovery
  attr_accessor :realised

  delegate :id, :loan, :recovered_on, :amount_due_to_dti, :to_key, to: :recovery
  delegate :reference, :business_name, :dti_amount_claimed, to: :loan, prefix: true

  def lender_loan_reference
    loan.lender_reference
  end

  def realised?
    @realised ? true : false
  end
end
