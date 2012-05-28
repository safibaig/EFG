module LoanPresenter
  extend ActiveSupport::Concern

  included do
    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::MassAssignmentSecurity

    attr_reader :loan

    delegate :errors, :valid?, to: :loan
  end

  module ClassMethods
    def attribute(name, options = {})
      methods = [name]

      unless options[:read_only]
        methods << "#{name}="
        attr_accessible name
      end

      delegate *methods, to: :loan
    end
  end

  def initialize(loan)
    @loan = loan
  end

  def attributes=(attributes)
    sanitize_for_mass_assignment(attributes).each do |k, v|
      public_send("#{k}=", v)
    end
  end

  def persisted?
    false
  end

  def save
    loan.save
  end
end
