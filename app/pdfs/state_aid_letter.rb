# encoding: utf-8
class StateAidLetter < Prawn::Document

  attr_reader :filename

  def initialize(loan, pdf_opts = {})
    super(pdf_opts)
    @loan = loan
    @filename = "state_aid_letter_#{loan.reference || loan.id}.pdf"
    self.font_size = 14
    build
  end

  private

  def build
    letterhead
    address
    title
    loan_details
    body_text1
    state_aid_text
    body_text2
  end

  def letterhead
    logo = @loan.lender.logo

    if logo && logo.exists?
      image logo.path, height: 50
    end
    move_down 40
  end

  def address
    text "Name", style: :bold
    move_down 10
    text "Address", style: :bold
    move_down 80
    text "Date", style: :bold
    move_down 20
  end

  def title
    text I18n.t('pdfs.state_aid_letter.title').upcase, size: 15, style: :bold
    move_down 20
  end

  def loan_details
    data = [
      ["Borrower:", @loan.business_name || '<undefined>'],
      ["Lender:", @loan.lender.name],
      ["Loan Reference Number:", @loan.reference || @loan.id],
      ["Loan Amount (£):", @loan.amount.format],
      ["Loan Term (Months):", @loan.repayment_duration.total_months],
      ["Anticipated drawdown date:", "tbc"]
    ]

    table(data) do
      cells.borders = []
      columns(0).font_style = :bold
    end

    move_down 20
  end

  def state_aid_text
    text I18n.t('pdfs.state_aid_letter.state_aid', amount: @loan.state_aid)
    move_down 20
  end

  def body_text1
    text I18n.t('pdfs.state_aid_letter.body_text1')
    move_down 20
  end

  def body_text2
    text I18n.t('pdfs.state_aid_letter.body_text2')
  end

end
