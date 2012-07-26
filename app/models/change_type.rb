class ChangeType < StaticAssociation
  self.data = [
    { id: '1', name: 'Business name' },
    { id: '2', name: 'Capital repayment holiday' },
    { id: '3', name: 'Change repayments' },
    { id: '4', name: 'Extend term' },
    { id: '5', name: 'Lender demand satisfied' },
    { id: '6', name: 'Lump sum repayment' },
    { id: '7', name: 'Record agreed draw' },
    { id: '8', name: 'Reprofile draws' },
    { id: '9', name: 'Data correction' },
    { id: 'a', name: 'Decrease term' }
  ]

  def self.for_loan_change
    all.reject { |change_type|
      change_type.id == '9'
    }
  end
end
