module StateAidCalculationVariant::LoanGuarantee
  include StateAidCalculationVariant::Base

  def self.to_param
    'loan_guarantee'
  end

  def page_header
    'Amend Draw Down Details'
  end

  def update_flash_message(state_aid_calculation)
    Flashes::StateAidCalculationFlashMessage.new(state_aid_calculation)
  end
end
