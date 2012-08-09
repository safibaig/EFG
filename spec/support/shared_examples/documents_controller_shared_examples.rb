shared_examples_for "documents controller action" do
  it 'works with a loan from the same lender' do
    dispatch

    response.should be_success
  end

  it 'renders PDF document' do
    dispatch

    response.content_type.should == 'application/pdf'
  end
end
