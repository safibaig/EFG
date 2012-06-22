# encoding: utf-8

require 'spec_helper'

describe StateAidLetter do

  let(:loan) { FactoryGirl.create(:loan, :offered, state_aid: Money.new(10000)) }

  let(:pdf) { StateAidLetter.new(loan) }

  describe "#render" do

    let(:output) {
      reader = PDF::Reader.new(StringIO.new(pdf.render))
      # Note: replace line breaks to make assertions easier
      reader.pages.collect { |page| page.to_s }.join(" ").gsub("\n", ' ')
    }

    it "should output a placeholder header" do
      output.should include(I18n.t('pdfs.letterhead_placeholder').upcase)
    end

    it "should output address fields" do
      output.should include('Name')
      output.should include('Address')
      output.should include('Date')
    end

    it "should output a title" do
      output.should include(I18n.t('pdfs.state_aid_letter.title').upcase)
    end

    it "should output loan details" do
      output.should include(loan.business_name)
      output.should include(loan.lender.name)
      output.should include(loan.id.to_s)
      output.should include(loan.amount.format)
      output.should include(loan.repayment_duration.total_months.to_s)
      output.should include("tbc")
    end

    it "should output body text" do
      output.should include(I18n.t('pdfs.state_aid_letter.body_text1').gsub("\n\n", ' '))
      output.should include(I18n.t('pdfs.state_aid_letter.body_text2').gsub("\n\n", ' '))
    end

    it "should output state aid calculation" do
      output.should include(I18n.t('pdfs.state_aid_letter.state_aid', :amount => loan.state_aid))
    end

  end

end
