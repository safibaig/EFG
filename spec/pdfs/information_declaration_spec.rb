# encoding: utf-8

require 'spec_helper'

describe InformationDeclaration do
  let(:lender) { FactoryGirl.create(:lender, name: 'Lender') }
  let(:loan) {
    FactoryGirl.create(:loan, lender: lender,
      amount: Money.new(12_345_67),
      business_name: 'ACME',
      company_registration: 'B1234567890',
      legal_form_id: 2,
      loan_category_id: 5,
      maturity_date: Date.new(2020, 3, 2),
      non_validated_postcode: 'XYZ 789',
      postcode: 'ABC 123',
      previous_borrowing: false,
      reason_id: 17,
      reference: 'QWERTY+01',
      repayment_duration: { months: 54 },
      repayment_frequency_id: 3,
      sic_code: 'A10.1.2',
      sic_desc: 'Foo',
      state_aid: Money.new(1_234_56, 'EUR'),
      town: 'Surbiton',
      trading_date: Date.new(1999, 1, 1),
      trading_name: 'ACME Trading',
      turnover: Money.new(5_000_000_00)
    )
  }

  let(:pdf_document) {
    information_declaration = InformationDeclaration.new(loan)
    PDF::Reader.new(StringIO.new(information_declaration.render))
  }

  let(:pdf_content) {
    # Note: replace line breaks to make assertions easier
    pdf_document.pages.collect { |page| page.to_s }.join(" ").gsub("\n", ' ')
  }

  let(:page_count) { pdf_document.pages.size }

  before do
    # PDF table output gets a jumbled up with long lines of text
    # so stub LoanCategory#name to be short enough to test
    fake_loan_category = LoanCategory.new.tap { |c| c.id = 1; c.name = "Category Name" }
    Loan.any_instance.stub(:loan_category).and_return(fake_loan_category)
  end

  describe "#render" do

    it "should contain a header" do
      pdf_content.should include('Information Declaration')
      pdf_content.should include("Lender organisation:Lender")
      pdf_content.should include("Business name:ACME")
      pdf_content.should include("EFG/SFLG reference:QWERTY+01")
      pdf_content.should include("Loan amount:£12,345.67")
    end

    it "should contain loan details" do
      pdf_content.should include('QWERTY+01')
      pdf_content.should include('ACME')
      pdf_content.should include('ACME Trading')
      pdf_content.should include('Partnership')
      pdf_content.should include('B1234567890')
      pdf_content.should include('£5,000,000.00')
      pdf_content.should include('01-01-1999')
      pdf_content.should include('ABC 123')
      pdf_content.should include('XYZ 789')
      pdf_content.should include('Surbiton')
      pdf_content.should include('£12,345.67')
      pdf_content.should include('4 years, 6 months')
      pdf_content.should include('Quarterly')
      pdf_content.should include('02-03-2020')
      pdf_content.should include('A10.1.2')
      pdf_content.should include('Foo')
      pdf_content.should include("Category Name")
      pdf_content.should include('Equipment purchase')
      pdf_content.should include('No')
      pdf_content.should include('€1,234.56')
      pdf_content.should include('Yes')
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
      page_count.times do |num|
        pdf_content.should include("Page: #{num + 1} of #{page_count}")
      end
    end

    it "should contain loan reference on every page" do
      pdf_content.scan("Loan: QWERTY+01").size.should == page_count
    end

  end

end
