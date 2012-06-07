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
    from_state = self.class.from_state
    allowed_from_states = from_state.is_a?(Array) ? from_state : [from_state]
    raise IncorrectLoanState unless allowed_from_states.include?(loan.state)
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
