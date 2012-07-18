class LoanTransfer
   include LoanPresenter
   include LoanStateTransition

   ALLOWED_LOAN_TRANSFER_STATES = [Loan::Guaranteed, Loan::Demanded, Loan::Repaid]

   attr_reader :loan_to_transfer, :new_loan

   attr_accessor :new_amount, :lender

   attribute :amount
   attribute :reference
   attribute :facility_letter_date
   attribute :declaration_signed

   attr_accessible :new_amount

   validates_presence_of :amount, :new_amount, :reference, :lender, :facility_letter_date

   validate do
     errors.add(:declaration_signed, :accepted) unless self.declaration_signed
   end

   def new_amount=(value)
     @new_amount = value.present? ? Money.parse(value) : nil
   end

   def loan_to_transfer
     @loan_to_transfer ||= Loan.where(
       reference: reference,
       amount: amount.cents,
       facility_letter_date: facility_letter_date,
       state: ALLOWED_LOAN_TRANSFER_STATES
     ).first
   end

   def save
     return false unless valid? && loan_can_be_transferred?
     Loan.transaction do

       loan_to_transfer.state = Loan::RepaidFromTransfer
       loan_to_transfer.save!

       @new_loan                       = loan_to_transfer.dup
       @new_loan.lender                = self.lender
       @new_loan.amount                = self.new_amount
       @new_loan.reference             = LoanReference.new(loan_to_transfer.reference).increment
       @new_loan.state                 = Loan::Incomplete
       @new_loan.branch_sortcode       = ''
       @new_loan.repayment_duration    = 0
       @new_loan.payment_period        = ''
       @new_loan.maturity_date         = ''
       @new_loan.invoice_id            = ''
       @new_loan.state_aid             = nil
       @new_loan.state_aid_is_valid    = false
       # TODO - assign loan allocation to one belonging to the new lender?
       # TODO - does notified aid need to change?
       # TODO - set created_by and modified by fields to user making transfer

       (1..5).each do |num|
         @new_loan.send("generic#{num}=", nil)
       end

       @new_loan.save!
     end
   end

   private

   def loan_can_be_transferred?
     unless loan_to_transfer.is_a?(Loan)
       errors.add(:base, :cannot_be_transferred)
       return false
     end

     if new_amount > loan_to_transfer.amount
       errors.add(:new_amount, :cannot_be_greater)
     end

     unless ALLOWED_LOAN_TRANSFER_STATES.include?(loan_to_transfer.state)
       errors.add(:base, :cannot_be_transferred)
     end

     if loan_to_transfer.already_transferred?
       errors.add(:base, :cannot_be_transferred)
     end

     if loan_to_transfer.lender == lender
       errors.add(:base, :cannot_transfer_own_loan)
     end

     errors.empty?
   end

end
