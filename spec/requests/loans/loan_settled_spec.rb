require 'spec_helper'

describe "loan settled" do
  let(:current_user) { FactoryGirl.create(:cfe_user) }
  before { login_as(current_user, scope: :user) }

  it "setting loans" do
    FactoryGirl.create(:lender, name: 'Hayes Inc')
    FactoryGirl.create(:lender, name: 'Carroll-Cronin')

    FactoryGirl.create(:loan, id: 1, reference: 'BSPFDNH-01')
    FactoryGirl.create(:loan, id: 2, reference: '3PEZRGB-01')
    FactoryGirl.create(:loan, id: 3, reference: 'LOGIHLJ-02')
    FactoryGirl.create(:loan, id: 4, reference: 'MF6XT4Z-01')

    visit(root_path)
    click_link 'Invoice Received'
  end
end
