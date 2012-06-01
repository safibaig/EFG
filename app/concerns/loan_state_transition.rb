module LoanStateTransition
  extend ActiveSupport::Concern

  class IncorrectLoanState < StandardError; end

  included do
    raise RuntimeError.new('LoanPresenter must be included.') unless ancestors.include?(LoanPresenter)
  end

  module ClassMethods
    def transition(options)
      @from_state = options[:from]
      @to_state = options[:to]
    end

    attr_reader :from_state, :to_state
  end

  def initialize(loan)
    raise IncorrectLoanState unless loan.state == self.class.from_state
    super(loan)
  end

  def transition_to
    self.class.to_state
  end

  def save
    super do |loan|
      loan.state = transition_to
    end
  end
end
