module LoanTypes
  class LoanType < Struct.new(:name, :scheme, :source)
  end

  LEGACY_SFLG = LoanType.new('Legacy SFLG', Loan::SFLG_SCHEME, Loan::LEGACY_SFLG_SOURCE)
  NEW_SFLG = LoanType.new('New SFLG', Loan::SFLG_SCHEME, Loan::SFLG_SOURCE)
  EFG = LoanType.new('EFG', Loan::EFG_SCHEME, Loan::SFLG_SOURCE)

  ALL = [LEGACY_SFLG, NEW_SFLG, EFG]
end
