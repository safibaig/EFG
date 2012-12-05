module StateAidCalculationVariant::Base
  def self.to_param
    raise NotImplementedError, 'StateAidCalculationVariant::Base is the default'
  end

  # Displayed on page header for the form.
  def page_header
    'State Aid Calculator'
  end

  # The path to redirect to when updated successfully or the process
  # is cancelled.
  def leave_state_aid_calculation_path(loan)
    loan_path(loan)
  end

  # The flash message value when the state aid calculation is
  # updated successfully.
  def update_flash_message(state_aid_calculation)
  end
end
