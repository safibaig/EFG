# encoding: utf-8

require 'spec_helper'

describe StateAidLetter do

  let(:loan) { FactoryGirl.create(:loan, :offered) }

  let(:pdf_content) {
    state_aid_letter = StateAidLetter.new(loan)
    reader = PDF::Reader.new(StringIO.new(state_aid_letter.render))
    # Note: replace line breaks to make assertions easier
    reader.pages.collect { |page| page.to_s }.join(" ").gsub("\n", ' ')
  }

  describe "#render" do

    it "should contain a placeholder header" do
      pdf_content.should include(I18n.t('pdfs.letterhead_placeholder').upcase)
    end

    it "should contain address fields" do
      pdf_content.should include('Name')
      pdf_content.should include('Address')
      pdf_content.should include('Date')
    end

    it "should contain a title" do
      pdf_content.should include(I18n.t('pdfs.state_aid_letter.title').upcase)
    end

    it "should contain loan details" do
      pdf_content.should include(loan.business_name)
      pdf_content.should include(loan.lender.name)
      pdf_content.should include(loan.reference)
      pdf_content.should include(loan.amount.format)
      pdf_content.should include(loan.repayment_duration.total_months.to_s)
      pdf_content.should include("tbc")
    end

    it "should contain body text" do
      pdf_content.should include(I18n.t('pdfs.state_aid_letter.body_text1').gsub("\n\n", ' '))
      pdf_content.should include(I18n.t('pdfs.state_aid_letter.body_text2').gsub("\n\n", ' '))
    end

    it "should contain state aid calculation" do
      pdf_content.should include(I18n.t('pdfs.state_aid_letter.state_aid', amount: loan.state_aid))
    end

  end

end
