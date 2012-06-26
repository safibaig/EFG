require 'spec_helper'

describe BasicSearch do

  describe "#loans" do

    let(:lender) { FactoryGirl.create(:lender) }

    let!(:loan1) {
      FactoryGirl.create(:loan, :offered, lender: lender)
    }

    let!(:loan2) {
      FactoryGirl.create(
        :loan,
        :guaranteed,
        lender: lender,
        business_name: "Inter-slice",
        trading_name: "Slice-inter",
        company_registration: "98877"
      )
    }

    it "should return loans by business name" do
      search(business_name: loan2.business_name).loans.should == [loan2]
    end

    it "should return loans by trading name" do
      search(trading_name: loan2.trading_name).loans.should == [loan2]
    end

    it "should return loans by company registration" do
      search(company_registration: loan2.company_registration).loans.should == [loan2]
    end

    it "should return loans by specific state" do
      search(state: Loan::Guaranteed).loans.should == [loan2]
    end

    it "should sort loans by business name" do
      loan1.update_attribute(:business_name, "DEF")
      loan2.update_attribute(:business_name, "ABC")

      search(sort_by: 'business_name').loans.should == [loan2, loan1]
    end

    it "should sort loans by trading name" do
      loan1.update_attribute(:trading_name, "DEF")
      loan2.update_attribute(:trading_name, "ABC")

      search(sort_by: 'trading_name').loans.should == [loan2, loan1]
    end

    it "should sort loans by amount" do
      loan1.update_attribute(:amount, Money.new(1000))
      loan2.update_attribute(:amount, Money.new(500))

      search(sort_by: 'amount').loans.should == [loan2, loan1]
    end

    it "should sort loans by postcode" do
      loan1.update_attribute(:postcode, 'EC1 ABC')
      loan2.update_attribute(:postcode, 'DA1 DEF')

      search(sort_by: 'postcode').loans.should == [loan2, loan1]
    end

    it "should sort loans by maturity date" do
      loan1.update_attribute(:maturity_date, 1.day.ago)
      loan2.update_attribute(:maturity_date, 2.days.ago)

      search(sort_by: 'maturity_date').loans.should == [loan2, loan1]
    end

    it "should sort loans by updated_at date" do
      loan1.update_attribute(:updated_at, 1.day.ago)
      loan2.update_attribute(:updated_at, 2.days.ago)

      search(sort_by: 'updated_at').loans.should == [loan2, loan1]
    end

    it "should sort loans by modified_by_legacy_id" do
      loan1.update_attribute(:modified_by_legacy_id, 2)
      loan2.update_attribute(:modified_by_legacy_id, 1)

      search(sort_by: 'modified_by_legacy_id').loans.should == [loan2, loan1]
    end

    it "should sort loans by amount in descending order" do
      loan1.update_attribute(:amount, Money.new(1000))
      loan2.update_attribute(:amount, Money.new(500))

      search(sort_by: 'modified_by_legacy_id', asc_desc: 'desc').loans.should == [loan1, loan2]
    end
  end

  private

  def search(params = {})
    BasicSearch.new(lender, params)
  end

end
