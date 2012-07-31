require 'active_model/model'

class LoanReport
  include ActiveModel::Model

  ALLOWED_LOAN_STATES = (Loan::States + ['All']).sort

  ALLOWED_LOAN_TYPES = [ Loan::SFLG_SOURCE, Loan::LEGACY_SFLG_SOURCE ]

  ALLOWED_LOAN_SCHEMES = [ "All", Loan::EFG_SCHEME, Loan::SFLG_SCHEME ]

  attr_accessor :facility_letter_start_date, :facility_letter_end_date,
                :created_at_start_date, :created_at_end_date,
                :last_modified_start_date, :last_modified_end_date,
                :loan_state, :created_by_user_id, :loan_type,
                :loan_scheme, :lender_id

  validates_presence_of :lender_id, :created_by_user_id

  validates_inclusion_of :loan_state, in: ALLOWED_LOAN_STATES

  validates_inclusion_of :loan_type, in: ALLOWED_LOAN_TYPES

  validates_inclusion_of :loan_scheme, in: ALLOWED_LOAN_SCHEMES

end
