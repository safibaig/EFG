class LegalForm < StaticAssociation
  self.data = [
    {id: 1, name: 'Sole Trader', requires_company_registration: false},
    {id: 2, name: 'Partnership', requires_company_registration: false},
    {id: 3, name: 'Limited-Liability Partnership (LLP)', requires_company_registration: true},
    {id: 4, name: 'Private Limited Company (LTD)', requires_company_registration: true},
    {id: 5, name: 'Public Limited Company (PLC)', requires_company_registration: true},
    {id: 6, name: 'Other', requires_company_registration: false},
  ]
end
