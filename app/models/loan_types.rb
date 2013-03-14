module LoanTypes
  class LoanType < Struct.new(:id, :name, :scheme, :source)
  end

  LEGACY_SFLG = LoanType.new('legacy_sflg', 'Legacy SFLG', Loan::SFLG_SCHEME, Loan::LEGACY_SFLG_SOURCE)
  NEW_SFLG = LoanType.new('new_sflg', 'New SFLG', Loan::SFLG_SCHEME, Loan::SFLG_SOURCE)
  EFG = LoanType.new('efg', 'EFG', Loan::EFG_SCHEME, Loan::SFLG_SOURCE)

  ALL = [LEGACY_SFLG, NEW_SFLG, EFG]
end
