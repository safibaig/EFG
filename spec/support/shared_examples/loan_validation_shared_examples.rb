shared_examples_for 'loan presenter that validates loan repayment frequency' do

  context "when repaying loan quarterly" do
    it "should require repayment duration to be divisible by 3" do
      loan_presenter.repayment_frequency_id = 3
      loan_presenter.repayment_duration = 19
      loan_presenter.should_not be_valid

      loan_presenter.repayment_duration = 18
      loan_presenter.should be_valid
    end
  end

  context "when repaying loan six monthly" do
    it "should require repayment duration to be divisible by 6" do
      loan_presenter.repayment_frequency_id = 2
      loan_presenter.repayment_duration = 11
      loan_presenter.should_not be_valid

      loan_presenter.repayment_duration = 12
      loan_presenter.should be_valid
    end
  end

  context "when repaying loan annually" do
    it "should require repayment duration to be divisible by 12" do
      loan_presenter.repayment_frequency_id = 1
      loan_presenter.repayment_duration = 25
      loan_presenter.should_not be_valid

      loan_presenter.repayment_duration = 24
      loan_presenter.should be_valid
    end
  end

end
