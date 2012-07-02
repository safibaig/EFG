require 'spec_helper'

describe "loan details" do

  shared_examples "rendering loan details" do
    before { loan.stub!(id: 1) }

    it "should render loan details" do
      assign(:loan, loan)
      render template: 'loans/details.html.erb'
    end
  end

  context "with a rejected loan" do
    let(:loan) { FactoryGirl.build(:loan, :rejected) }

    pending "needs factory definition"
    # include_examples 'rendering loan details'
  end

  context "with an eligible loan" do
    let(:loan) { FactoryGirl.build(:loan, :eligible) }

    pending "needs factory definition"
    # include_examples 'rendering loan details'
  end

  context "with a cancelled loan" do
    let(:loan) { FactoryGirl.build(:loan, :cancelled) }

    include_examples 'rendering loan details'
  end

  context "with an incomplete loan" do
    let(:loan) { FactoryGirl.build(:loan, :incomplete) }

    include_examples 'rendering loan details'
  end

  context "with a completed loan" do
    let(:loan) { FactoryGirl.build(:loan, :completed) }

    include_examples 'rendering loan details'
  end

  context "with an offered loan" do
    let(:loan) { FactoryGirl.build(:loan, :offered) }

    include_examples 'rendering loan details'
  end

  context "with a guaranteed loan" do
    let(:loan) { FactoryGirl.build(:loan, :guaranteed) }

    include_examples 'rendering loan details'
  end

  context "with a lender demanded loan" do
    let(:loan) { FactoryGirl.build(:loan, :lender_demand) }

    include_examples 'rendering loan details'
  end

  context "with a repaid loan" do
    let(:loan) { FactoryGirl.build(:loan, :repaid) }

    include_examples 'rendering loan details'
  end

  context "with a not demanded loan" do
    let(:loan) { FactoryGirl.build(:loan, :not_demanded) }

    include_examples 'rendering loan details'
  end

  context "with a demanded loan" do
    let(:loan) { FactoryGirl.build(:loan, :demanded) }

    include_examples 'rendering loan details'
  end

  context "with an auto cancelled loan" do
    let(:loan) { FactoryGirl.build(:loan, :auto_cancelled) }

    pending "needs factory definition"
    # include_examples 'rendering loan details'
  end

  context "with a removed loan" do
    let(:loan) { FactoryGirl.build(:loan, :removed) }

    include_examples 'rendering loan details'
  end

  context "with a repaid from transfer loan" do
    let(:loan) { FactoryGirl.build(:loan, :repaid_from_transfer) }

    pending "needs factory definition"
    # include_examples 'rendering loan details'
  end

  context "with an auto removed loan" do
    let(:loan) { FactoryGirl.build(:loan, :auto_removed) }

    pending "needs factory definition"
    # include_examples 'rendering loan details'
  end

  context "with a settled loan" do
    let(:loan) { FactoryGirl.build(:loan, :settled) }

    include_examples 'rendering loan details'
  end

  context "with a realised loan" do
    let(:loan) { FactoryGirl.build(:loan, :realised) }

    include_examples 'rendering loan details'
  end

  context "with a recovered loan" do
    let(:loan) { FactoryGirl.build(:loan, :recovered) }

    include_examples 'rendering loan details'
  end

  context "with an incomplete legacy loan" do
    let(:loan) { FactoryGirl.build(:loan, :incomplete_legacy) }

    pending "needs factory definition"
    # include_examples 'rendering loan details'
  end

  context "with a complete legacy loan" do
    let(:loan) { FactoryGirl.build(:loan, :complete_legacy) }

    pending "needs factory definition"
    # include_examples 'rendering loan details'
  end

  context 'without a loan allocation' do
    let(:loan) { FactoryGirl.build(:loan, :guaranteed, loan_allocation_id: nil) }

    include_examples 'rendering loan details'
  end
end
