module LoanStateTransition
  extend ActiveSupport::Concern

  class IncorrectLoanState < StandardError
    def initialize(presenter, loan)
      message = "#{presenter.class.name} tried to transition Loan:#{loan.id} with state:#{loan.state}"
      super(message)
    end
  end

  included do
    raise RuntimeError.new('LoanPresenter must be included.') unless ancestors.include?(LoanPresenter)

    before_save :transition_state
    after_save :log_state_change!
  end

  module ClassMethods
    def transition(options)
      @from_state = options[:from]
      @to_state = options[:to]
      @event = options[:event]
    end

    attr_reader :from_state, :to_state, :event
  end

  def initialize(loan)
    from_state = self.class.from_state
    allowed_from_states = from_state.is_a?(Array) ? from_state : [from_state]
    raise IncorrectLoanState.new(self, loan) unless allowed_from_states.include?(loan.state)
    super(loan)
  end

  def transition_to
    self.class.to_state
  end

  def event
    self.class.event
  end

  def transition_state
    loan.state = transition_to
  end

  def log_state_change!
    LoanStateChange.log(loan, event.id, loan.modified_by)
  end

end
