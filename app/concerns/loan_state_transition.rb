module LoanStateTransition
  extend ActiveSupport::Concern

  included do
    attr_reader :loan
  end

  module ClassMethods
    def attribute(name)
      delegate name, "#{name}=", to: :loan
    end
  end

  def initialize(loan)
    @loan = loan
  end
end
