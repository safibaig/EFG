module LoanAlerts
  autoload :LoanAlert,                    'loan_alerts/loan_alert'
  autoload :NotClosedGuaranteedLoanAlert, 'loan_alerts/not_closed_guaranteed_loan_alert'
  autoload :NotClosedOfferedLoanAlert,    'loan_alerts/not_closed_offered_loan_alert'
  autoload :NotDemandedLoanAlert,         'loan_alerts/not_demanded_loan_alert'
  autoload :NotDrawnLoanAlert,            'loan_alerts/not_drawn_loan_alert'
  autoload :NotProgressedLoanAlert,       'loan_alerts/not_progressed_loan_alert'
  autoload :SFLGNotClosedLoanAlert,       'loan_alerts/sflg_not_closed_loan_alert'
end
