shared_examples_for "loan alerts controller" do

  context "with high priority" do
    before do
      dispatch(priority: :high)
    end

    it "loads only high priority loans" do
      assigns(:loans).should == [high_priority_loan]
    end
  end

  context "with medium priority" do
    before do
      dispatch(priority: :medium)
    end

    it "loads only medium priority loans" do
      assigns(:loans).should == [medium_priority_loan]
    end
  end

  context "with low priority" do
    before do
      dispatch(priority: :low)
    end

    it "loads only low priority loans" do
      assigns(:loans).should == [low_priority_loan]
    end
  end

  context "with no priority" do
    before do
      dispatch
    end

    it "loads only low priority loans" do
      loans = assigns(:loans)

      loans.should include(high_priority_loan)
      loans.should include(medium_priority_loan)
      loans.should include(low_priority_loan)
    end
  end

end
