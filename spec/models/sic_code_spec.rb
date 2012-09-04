require 'spec_helper'

describe SicCode do

  describe "validations" do
    let(:sic_code) { FactoryGirl.build(:sic_code) }

    it 'has a valid Factory' do
      sic_code.should be_valid
    end

    it 'requires a code' do
      sic_code.code = nil
      sic_code.should_not be_valid
    end

    it 'requires a description' do
      sic_code.description = nil
      sic_code.should_not be_valid
    end

    it 'requires eligible' do
      sic_code.eligible = nil
      sic_code.should_not be_valid
    end

    it 'requires public_sector_restricted' do
      sic_code.public_sector_restricted = nil
      sic_code.should_not be_valid
    end
  end

end
