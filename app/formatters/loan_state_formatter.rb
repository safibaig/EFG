module LoanStateFormatter

  def self.humanize(state)
    {
      Loan::Rejected           => 'Rejected',
      Loan::Eligible           => 'Eligible',
      Loan::Cancelled          => 'Cancelled',
      Loan::Incomplete         => 'Incomplete',
      Loan::Completed          => 'Complete',
      Loan::Offered            => 'Offered',
      Loan::Guaranteed         => 'Guaranteed',
      Loan::LenderDemand       => 'Lender demand',
      Loan::Repaid             => 'Repaid',
      Loan::NotDemanded        => 'Not demanded',
      Loan::Demanded           => 'Demanded',
      Loan::AutoCancelled      => 'Auto-cancelled',
      Loan::Removed            => 'Removed',
      Loan::RepaidFromTransfer => 'Repaid from transfer',
      Loan::AutoRemoved        => 'Auto-Removed',
      Loan::Settled            => 'Settled',
      Loan::Realised           => 'Realised',
      Loan::Recovered          => 'Recovered',
      Loan::IncompleteLegacy   => 'Incomplete (legacy)',
      Loan::CompleteLegacy     => 'Complete (legacy)'
    }[state]
  end

end
