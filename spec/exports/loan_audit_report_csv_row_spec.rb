require 'spec_helper'

describe LoanAuditReportCsvRow do

  describe "#row" do

    let(:user) { FactoryGirl.create(:user) }

    let!(:loan) {
      loan = FactoryGirl.create(
        :loan,
        reference: 'ABC123',
        amount: Money.new(500_000_00),
        maturity_date: Date.parse('28/05/2011'),
        cancelled_on: Date.parse('30/12/2012'),
        facility_letter_date: Date.parse('16/06/2012'),
        borrower_demanded_on: Date.parse('16/08/2012'),
        repaid_on: Date.parse('19/02/2014'),
        no_claim_on: Date.parse('13/08/2012'),
        dti_demanded_on: Date.parse('20/05/2011'),
        settled_on: Date.parse('03/07/2012'),
        remove_guarantee_on: Date.parse('24/04/2012'),
        generic1: 'Generic1',
        generic2: 'Generic2',
        generic3: 'Generic3',
        generic4: 'Generic4',
        generic5: 'Generic5',
        reason_id: 1,
        loan_category_id: 2,
        state: Loan::Guaranteed,
        created_at: Time.zone.parse('12/04/2012 14:34'),
        updated_at: Time.zone.parse('13/04/2012 14:34')
      )

      # stub custom fields that are created by LoanAuditReport SQL query
      loan.stub(
        lender_reference_code: 'DEF',
        loan_created_by: user.username,
        loan_modified_by: user.username,
        loan_state_change_to_state: Loan::AutoCancelled,
        loan_state_change_event_id: 3,
        loan_state_change_modified_at: Time.parse('11/06/2012 11:00'),
        loan_state_change_modified_by: user.username,
        loan_initial_draw_date: Date.parse('03/06/2012')
      )

      loan
    }

    let(:row) { LoanAuditReportCsvRow.new(loan, 2, Loan::Offered).to_a }

    it 'should CSV data for loan' do
      row[0].should == "ABC123"                       # loan_reference
      row[1].should == "DEF"                          # lender_id
      row[2].should == Money.new(500_000_00).format   # facility_amount
      row[3].should == '28-05-2011'                   # maturity_date
      row[4].should == '30-12-2012'                   # cancellation_date
      row[5].should == '16-06-2012'                   # scheme_facility_letter_date
      row[6].should == '03-06-2012'                   # initial_draw_date
      row[7].should == '16-08-2012'                   # lender_demand_date
      row[8].should == '19-02-2014'                   # repaid_date
      row[9].should == '13-08-2012'                   # no_claim_date
      row[10].should == '20-05-2011'                  # government_demand_date
      row[11].should == '03-07-2012'                  # settled_date
      row[12].should == '24-04-2012'                  # guarantee_remove_date
      row[13].should == 'Generic1'                    # generic1
      row[14].should == 'Generic2'                    # generic2
      row[15].should == 'Generic3'                    # generic3
      row[16].should == 'Generic4'                    # generic4
      row[17].should == 'Generic5'                    # generic5
      row[18].should == LoanReason.find(1).name       # loan_reason
      row[19].should == LoanCategory.find(2).name     # loan_category
      row[20].should == Loan::Guaranteed.humanize     # loan_state
      row[21].should == '12-04-2012 02:34 PM'         # created_at
      row[22].should == user.username                 # created_by
      row[23].should == '13-04-2012 02:34 PM'         # modified_date
      row[24].should == user.username                 # modified_by
      row[25].should == "2"                           # audit_record_sequence
      row[26].should == "Offered"                     # from_state
      row[27].should == "Auto-cancelled"              # to_state
      row[28].should == LoanEvent.find(3).name        # loan_function
      row[29].should == "11-06-2012 11:00 AM"         # audit_record_modified_at
      row[30].should == user.username                 # audit_record_modified_by
    end

  end

end
