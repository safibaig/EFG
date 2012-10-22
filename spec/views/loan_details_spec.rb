require 'spec_helper'

describe 'loans/details' do

  shared_examples "rendered loan_details" do
    before { loan.stub!(id: 1) if loan.new_record? }

    let(:all_details) {
      %w(
        loan_cancel.cancelled_comment
        loan_offer.facility_letter_sent
        loan_guarantee.received_declaration
        loan_demand_to_borrower.borrower_demanded_on
        loan_remove.remove_guarantee_outstanding_amount
        loan_repay.repaid_on
        loan_no_claim.no_claim_on
        loan_demand_against_government.dti_demanded_on
        loan_settle_claim.settled_on
        loan_recovery.recovery_on
        loan_realise.realised_money_date
      )
    }

    let(:not_visible_details) { all_details - visible_details }

    # Define visible_details in each individual spec

    it "should render only details relevant to the loan" do
      assign(:loan, loan)

      render

      # every loan displays loan entry details
      rendered.should have_content(I18n.t("simple_form.labels.loan_entry.business_name"))

      visible_details.each do |key|
        rendered.should have_content(I18n.t("simple_form.labels.#{key}"))
      end

      not_visible_details.each do |key|
        rendered.should_not have_content(I18n.t("simple_form.labels.#{key}"))
      end

    end
  end

  context "with a rejected loan" do
    let(:loan) { FactoryGirl.build(:loan, :rejected) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_entry.business_name) }
    end
  end

  context "with an eligible loan" do
    let(:loan) { FactoryGirl.build(:loan, :eligible) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_entry.business_name) }
    end
  end

  context "with a cancelled loan" do
    let(:loan) { FactoryGirl.build(:loan, :cancelled) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_cancel.cancelled_comment) }
    end
  end

  context "with an incomplete loan" do
    let(:loan) { FactoryGirl.build(:loan, :incomplete) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_entry.business_name) }
    end
  end

  context "with a completed loan" do
    let(:loan) { FactoryGirl.build(:loan, :completed) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_entry.business_name) }
    end
  end

  context "with an offered loan" do
    let(:loan) { FactoryGirl.build(:loan, :offered) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_offer.facility_letter_sent) }
    end
  end

  context "with a guaranteed loan" do
    let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_guarantee.received_declaration) }
    end

    context 'without an initial_draw_change' do
      before do
        loan.loan_modifications.delete_all
      end

      it 'does not blow up' do
        assign(:loan, loan)
        render
      end
    end

    context 'without a LendingLimit' do
      before do
        loan.lending_limit = nil
      end

      it_behaves_like 'rendered loan_details' do
        let(:visible_details) { %w(loan_guarantee.received_declaration) }
      end
    end
  end

  context "with a lender demanded loan" do
    let(:loan) { FactoryGirl.build(:loan, :lender_demand) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_demand_to_borrower.borrower_demanded_on) }
    end
  end

  context "with a repaid loan" do
    let(:loan) { FactoryGirl.build(:loan, :repaid) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_repay.repaid_on) }
    end
  end

  context "with a not demanded loan" do
    let(:loan) { FactoryGirl.build(:loan, :not_demanded) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_no_claim.no_claim_on) }
    end
  end

  context "with a demanded loan" do
    let(:loan) { FactoryGirl.build(:loan, :demanded) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_demand_against_government.dti_demanded_on) }
    end
  end

  context "with a removed loan" do
    let(:loan) { FactoryGirl.build(:loan, :removed) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_remove.remove_guarantee_outstanding_amount) }
    end
  end

  context "with a repaid from transfer loan" do
    let(:loan) { FactoryGirl.build(:loan, :repaid_from_transfer) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w() }
    end
  end

  context "with a settled loan" do
    let(:loan) { FactoryGirl.create(:loan, :settled) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_settle_claim.settled_on) }
    end

    it 'does not include invoice details if it has no invoice' do
      loan.invoice = nil
      assign(:loan, loan)
      render
      rendered.should_not have_content('invoice reference')
    end
  end

  context "with a realised loan" do
    let(:loan) { FactoryGirl.build(:loan, :realised) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_realise.realised_money_date) }
    end
  end

  context "with a recovered loan" do
    let(:loan) { FactoryGirl.build(:loan, :recovered) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_recovery.recovery_on) }
    end
  end

  context "with a complete legacy loan" do
    let(:loan) { FactoryGirl.build(:loan, :complete_legacy) }

    it_behaves_like 'rendered loan_details' do
      let(:visible_details) { %w(loan_entry.business_name) }
    end
  end
end
