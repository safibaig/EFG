class EligibilityDecisionEmail

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :email

  validates_presence_of :email

  def initialize(params = {})
    @email = params[:email]
  end

  def persisted?
    false
  end

end
