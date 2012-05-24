require 'active_model/model'

class LoanOffer
  include ActiveModel::Model

  ATTRIBUTES = [:facility_letter_date, :facility_letter_sent]

  ATTRIBUTES.each do |attribute|
    delegate attribute, "#{attribute}=", to: :loan
  end
  delegate :errors, :save, to: :loan

  attr_reader :loan

  def initialize(loan, attributes = {})
    @loan = loan
    super(attributes)
  end
end
