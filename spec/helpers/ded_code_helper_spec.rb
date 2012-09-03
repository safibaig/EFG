require 'spec_helper'

describe DedCodeHelper do

  describe "#grouped_ded_code_options" do
    let!(:ded_code1) {
      FactoryGirl.create(
        :ded_code,
        group_description: 'Trading',
        category_description: 'Loss of Market',
        code: 'A.10.10',
        code_description: 'Competition'
      )
    }

    let!(:ded_code2) {
      FactoryGirl.create(
        :ded_code,
        group_description: 'Non-trading',
        category_description: 'Living beyond means',
        code: 'B.10.99',
        code_description: 'Not classified'
      )
    }

    it "should return hash of DED codes suitable for select menu" do
      grouped_ded_codes.should == {
        'Loss of Market' => [ ['A.10.10 - Competition', 'A.10.10'] ],
        'Living beyond means' => [ ['B.10.99 - Not classified', 'B.10.99'] ]
      }
    end
  end

end
