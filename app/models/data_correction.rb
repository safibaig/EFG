class DataCorrection < LoanModification
  belongs_to :old_lending_limit, class_name: 'LendingLimit'
  belongs_to :lending_limit

  def change_type_name
    'Data correction'
  end
end
