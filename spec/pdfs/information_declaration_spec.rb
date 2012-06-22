# encoding: utf-8

require 'spec_helper'

describe InformationDeclaration do

  let(:loan) { FactoryGirl.create(:loan, :offered) }

  let(:pdf_document) {
    information_declaration = InformationDeclaration.new(loan)
    PDF::Reader.new(StringIO.new(information_declaration.render))
  }

  let(:pdf_content) {
    # Note: replace line breaks to make assertions easier
    pdf_document.pages.collect { |page| page.to_s }.join(" ").gsub("\n", ' ')
  }

  before do
    # PDF table output gets a jumbled up with long lines of text
    # so stub LoanCategory#name to be short enough to test
    fake_loan_category = LoanCategory.new.tap { |c| c.id = 1; c.name = "Category Name" }
    Loan.any_instance.stub(:loan_category).and_return(fake_loan_category)
  end

  describe "#render" do

    it "should contain a header" do
      pdf_content.should match(/^Information Declaration/)
      pdf_content.should include("Lender organisation:#{loan.lender.name}")
      pdf_content.should include("Business name:#{loan.business_name}")
      pdf_content.should include("SFLG reference number:#{loan.reference}")
      pdf_content.should include("Loan amount:#{loan.amount.format}")
    end

    it "should contain loan details" do
      pdf_content.should include(loan.reference)
      pdf_content.should include(loan.business_name)
      pdf_content.should include(loan.trading_name)
      pdf_content.should include(loan.legal_form.name)
      pdf_content.should include(loan.company_registration)
      pdf_content.should include(loan.turnover.format)
      pdf_content.should include(loan.trading_date.strftime('%d-%m-%Y'))
      pdf_content.should include(loan.postcode)
      pdf_content.should include(loan.non_validated_postcode)
      pdf_content.should include(loan.town)
      pdf_content.should include(loan.amount.format)
      pdf_content.should include(loan.repayment_duration.format)
      pdf_content.should include(loan.repayment_frequency.name)
      pdf_content.should include(loan.maturity_date.strftime('%d-%m-%Y'))
      pdf_content.should include(loan.sic_code)
      pdf_content.should include(loan.sic_code_description)
      pdf_content.should include("Category Name")
      pdf_content.should include(loan.reason.name)
      pdf_content.should include(loan.previous_borrowing ? "Yes" : "No")
      pdf_content.should include(loan.state_aid.format)
      pdf_content.should include(loan.state_aid_is_valid ? "Yes" : "No")
    end

    it "should contain declaration text" do
      pdf_content.should include(I18n.t('pdfs.information_declaration.declaration').gsub("\n", ''))
      pdf_content.should include(I18n.t('pdfs.information_declaration.declaration_list').gsub("\n", ''))
      pdf_content.should include(I18n.t('pdfs.information_declaration.declaration_important').gsub(/<\/?\w+>/, ''))
    end

    it "should contain signature text" do
      pdf_content.scan(/Signed________/).size.should == 4
      pdf_content.scan(/Print name________/).size.should == 4
      pdf_content.scan(/Position________/).size.should == 4
      pdf_content.scan(/Date________/).size.should == 4

      pdf_content.should include(I18n.t('pdfs.information_declaration.signatories'))
    end

    it "should contain page numbers" do
      page_count = pdf_document.pages.size

      page_count.times do |num|
        pdf_content.should include("Page: #{num + 1} of #{page_count}")
      end
    end

  end

end
