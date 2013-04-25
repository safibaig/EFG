# encoding: utf-8

class RealiseRecovery
  class NotMarkedAsRealised < RuntimeError
  end

  include ActiveModel::Model

  def initialize(recovery)
    @recovery = recovery
  end

  attr_reader :recovery
  attr_accessor :realised, :post_claim_limit

  delegate :id, :loan, :recovered_on, :amount_due_to_dti, :to_key, to: :recovery
  delegate :reference, :business_name, :dti_amount_claimed, to: :loan, prefix: true

  def lender_loan_reference
    loan.lender_reference
  end

  def realised?
    realised = (@realised ? true : false)
    realised || post_claim_limit?
  end

  def post_claim_limit?
    @post_claim_limit ? true : false
  end

  def realise!(realisation_statement, modifier)
    raise NotMarkedAsRealised unless realised?

    recovery.realisation_statement = realisation_statement
    recovery.realise_flag = true
    recovery.save!

    realisation = realisation_statement.loan_realisations.build
    realisation.realised_loan = loan
    realisation.created_by = modifier
    realisation.realised_amount = amount_due_to_dti
    realisation.realised_on = Date.today
    realisation.post_claim_limit = post_claim_limit?
    realisation.save!
  end
end
