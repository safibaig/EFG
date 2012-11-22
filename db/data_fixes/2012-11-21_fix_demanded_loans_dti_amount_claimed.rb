# A bug when calculating Loan#dti_amount_claimed
# for non-EFG loans resulted in #dti_interest and
# #dti_break_costs not being included in the
# calculation.
#
# This script recalculates #dti_amount_claimed
# for all non-EFG loans demanded or data corrected
# since go-live (ignoring loans that do not
# have dti_interest and dti_break_costs).

ActiveRecord::Base.transaction do
  loan_state_changes = LoanStateChange.
                        joins(:loan).
                        where('modified_at > "2012-10-20"').
                        where("loans.loan_scheme != 'E'").
                        where("loans.dti_interest != 0 OR loans.dti_break_costs != 0").
                        where(event_id: [LoanEvent::DemandAgainstGovernmentGuarantee.id, LoanEvent::DataCorrection.id]).
                        includes(:loan)

  loans = loan_state_changes.collect(&:loan)

  progress_bar = ProgressBar.new("Fix #{loans.count} loans", loans.count)

  loans.each do |loan|
    loan.calculate_dti_amount_claimed
    loan.save!
    progress_bar.inc
  end

  progress_bar.finish
end
