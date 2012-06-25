shared_examples_for "documents controller action" do

  let(:loan) { FactoryGirl.create(:loan, :completed, lender: current_lender) }

  it 'works with a loan from the same lender' do
    dispatch id: loan.id

    response.should be_success
  end

  it 'raises RecordNotFound for a loan from another lender' do
    other_lender = FactoryGirl.create(:lender)
    loan = FactoryGirl.create(:loan, :completed, lender: other_lender)

    expect {
      dispatch id: loan.id
    }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'renders PDF document' do
    dispatch id: loan.id

    response.content_type.should == 'application/pdf'
  end

end
