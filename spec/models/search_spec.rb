require 'spec_helper'

describe Search do
  describe "setting search filters" do
    let(:lender) { double(Lender) }

    it "should remove blank values" do
      search = Search.new(lender, 'business_name' => '')
      search.business_name.should be_nil
    end
  end

  describe "#sort_by" do
    let(:lender) { double(Lender) }

    it "should return the default" do
      search = Search.new(lender)
      search.sort_by.should == Search::DefaultSortBy
    end

    it "should return a valid, user supplied value" do
      search = Search.new(lender, {'sort_by' => 'trading_name'})
      search.sort_by.should == 'trading_name'
    end

    it "should return the default, if passed an invalid value" do
      search = Search.new(lender, {'sort_by' => 'fake_attribute'})
      search.sort_by.should == Search::DefaultSortBy
    end
  end

  describe "#sort_order" do
    let(:lender) { double(Lender) }

    it "should return the default" do
      search = Search.new(lender)
      search.sort_order.should == Search::DefaultSortOrder
    end

    it "should return a valid, user supplied value" do
      search = Search.new(lender, {'sort_order' => 'ASC'})
      search.sort_order.should == 'ASC'
    end

    it "should return the default, if passed an invalid value" do
      search = Search.new(lender, {'sort_by' => 'JUNK'})
      search.sort_order.should == Search::DefaultSortOrder
    end
  end

  describe "#results" do
    let!(:lender) { FactoryGirl.create(:lender) }
    let!(:loan1) { FactoryGirl.create(:loan, :offered, lender: lender) }
    let!(:user) { FactoryGirl.create(:lender_user, lender: lender) }
    let!(:loan2) {
      FactoryGirl.create(
        :loan,
        :guaranteed,
        lender: lender,
        amount: Money.new(10_000_000_00),
        business_name: "Inter-slice",
        trading_name: "Slice-inter",
        company_registration: "98877",
        maturity_date: '10/05/2050',
        reason_id: 22,
        postcode: "S2 4LA",
        updated_at: 1.week.from_now,
        modified_by: user,
        generic1: 'generic 1 text',
        generic2: 'generic 2 text',
        generic3: 'generic 3 text',
        generic4: 'generic 4 text',
        generic5: 'generic 5 text',
      )
    }

    def search(params = {})
      Search.new(lender, params)
    end

    it "should return loans by partial business name" do
      search('business_name' => 'er-sl').results.should == [loan2]
    end

    it "should return loans by partial trading name" do
      search('trading_name' => 'ce-int').results.should == [loan2]
    end

    it "should return loans by partial company registration" do
      search('company_registration' => '887').results.should == [loan2]
    end

    it "should return loans by specific state" do
      search('state' => Loan::Guaranteed).results.should == [loan2]
    end

    it "should return loans by specific lending limit" do
      search('lending_limit_id' => loan2.lending_limit_id).results.should == [loan2]
    end

    it "should return loans on or above a specific amount" do
      search('amount_from' => Money.new(10_000_000_00)).results.should == [loan2]
    end

    it "should return loans on or below a specific amount" do
      search('amount_to' => Money.new(9_000_000_00)).results.should == [loan1]
    end

    it "should return loans on or after a specific maturity date" do
      search('maturity_date_from' => '10/05/2050').results.should == [loan2]
    end

    it "should return loans on or before a specific maturity date" do
      search('maturity_date_to' => '10/05/2049').results.should == [loan1]
    end

    it "should return loans by specific loan reason" do
      search('reason_id' => loan2.reason_id).results.should == [loan2]
    end

    it "should return loans by specific loan reason" do
      search('reason_id' => loan2.reason_id).results.should == [loan2]
    end

    it "should return loans by partial postcode" do
      search('postcode' => '4L').results.should == [loan2]
    end

    it "should return loans on or after a specific updated at date" do
      search('updated_at_from' => 1.day.from_now.strftime("%d/%m/%Y")).results.should == [loan2]
    end

    it "should return loans on or before a specific updated at date" do
      search('updated_at_to' => 1.day.from_now.strftime("%d/%m/%Y")).results.should == [loan1]
    end

    it "should return loans by a specific modified by user" do
      search('modified_by_id' => user.id).results.should == [loan2]
    end

    (1..5).each do |num|
      it "should return loans by partial generic field #{num}" do
        search("generic#{num}" => "eric #{num}").results.should == [loan2]
      end
    end

    it "should sort loans by business name" do
      loan1.update_attribute(:business_name, "DEF")
      loan2.update_attribute(:business_name, "ABC")

      search('sort_by' => 'business_name').results.should == [loan1, loan2]
    end

    it "should sort loans by trading name" do
      loan1.update_attribute(:trading_name, "DEF")
      loan2.update_attribute(:trading_name, "ABC")

      search('sort_by' => 'trading_name').results.should == [loan1, loan2]
    end

    it "should sort loans by postcode" do
      loan1.update_attribute(:postcode, 'EC1 ABC')
      loan2.update_attribute(:postcode, 'DA1 DEF')

      search('sort_by' => 'postcode').results.should == [loan1, loan2]
    end

    it "should sort loans by maturity date" do
      loan1.update_attribute(:maturity_date, 1.day.ago)
      loan2.update_attribute(:maturity_date, 2.days.ago)

      search('sort_by' => 'maturity_date').results.should == [loan1, loan2]
    end

    it "should sort loans by updated_at date" do
      loan1.update_attribute(:updated_at, 1.day.ago)
      loan2.update_attribute(:updated_at, 2.days.ago)

      search('sort_by' => 'updated_at').results.should == [loan1, loan2]
    end

    it "should sort loans by amount in ascending order" do
      loan1.update_attribute(:amount, Money.new(1000))
      loan2.update_attribute(:amount, Money.new(500))

      search('sort_by' => 'amount', 'sort_order' => 'ASC').results.should == [loan2, loan1]
    end
  end
end
