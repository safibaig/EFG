# encoding: utf-8

class SettleLoan
  class NotMarkedAsSettled < RuntimeError
  end

  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Demanded, to: Loan::Settled, event: LoanEvent::CreateClaim

  attribute :id, read_only: true
  attribute :lending_limit, read_only: true
  attribute :reference, read_only: true
  attribute :lender_reference, read_only: true
  attribute :business_name, read_only: true
  attribute :corrected?, read_only: true
  attribute :dti_amount_claimed, read_only: true
  attribute :dti_demanded_on, read_only: true

  attribute :legacy_loan?, read_only: true
  attribute :sflg?, read_only: true
  attribute :efg_loan?, read_only: true

  attr_accessor :settled
  attr_reader :settled_amount

  validates_presence_of :settled_amount

  validate do |presenter|
    if presenter.settled_amount
      if presenter.settled_amount < Money.new(0)
        errors.add(:settled_amount, :greater_than_or_equal_to, count: '£0.00')
      end

      if presenter.settled_amount > loan.dti_amount_claimed
        errors.add(:settled_amount, :less_than_or_equal_to, count: loan.dti_amount_claimed.format)
      end
    end
  end

  def initialize(loan)
    super
    @settled_amount = loan.dti_amount_claimed
  end

  def settled?
    @settled ? true : false
  end

  def settled_amount=(value)
    if value.present?
      @settled_amount = Money.parse(value)
    else
      @settled_amount = nil
    end
  end

  def settle!(invoice, modifier)
    raise NotMarkedAsSettled unless settled?
    raise ActiveRecord::RecordInvalid.new(self) unless valid?

    self.modified_by = modifier
    loan.invoice = invoice
    loan.settled_on = Date.today
    loan.settled_amount = self.settled_amount
    save
  end

  def to_key
    loan.to_key
  end

  protected :save
end