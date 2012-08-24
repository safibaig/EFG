module LoanPresenter
  extend ActiveSupport::Concern

  included do
    extend  ActiveModel::Naming
    extend  ActiveModel::Callbacks
    include ActiveModel::Conversion
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Validations

    attr_reader :loan

    delegate :modified_by, :modified_by=, to: :loan

    define_model_callbacks :save
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
    return false unless valid?
    loan.transaction do
      run_callbacks :save do
        loan.save!
      end
    end
  end

end
