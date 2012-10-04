class LegalForm < StaticAssociation
  self.data = [
    {id: 1, name: 'Sole Trader'},
    {id: 2, name: 'Partnership'},
    {id: 3, name: 'Limited-Liability Partnership (LLP)'},
    {id: 4, name: 'Private Limited Company (LTD)'},
    {id: 5, name: 'Public Limited Company (PLC)'},
    {id: 6, name: 'Other'},
  ]

  def self.requiring_company_registration
    (3..5).collect { |id| find(id) }
  end
end
