module LoanStateTransition
  extend ActiveSupport::Concern

  included do
    extend  ActiveModel::Naming
    include ActiveModel::Conversion

    attr_reader :loan
  end

  module ClassMethods
    def attribute(name, options = {})
      methods = [name]
      methods << "#{name}=" unless options[:read_only]
      delegate *methods, to: :loan
    end
  end

  def initialize(loan)
    @loan = loan
  end

  def persisted?
    false
  end
end
