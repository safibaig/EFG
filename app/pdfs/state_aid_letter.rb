# encoding: utf-8

class StateAidLetter #< Document::Base

  attr_reader :pdf

  def initialize(loan)
    @loan = loan
    @pdf  = Prawn::Document.new(page_size: "A4", top_margin: 100)
    @pdf.font_size = 14
    build
  end

  private

  def build
    # text letterhead.upcase, style: :italic, align: :center
    move_down 20
    address
    move_down 20
    text title.upcase, size: 15, style: :bold
    move_down 20
    loan_details
    move_down 20
    text body_text1
    move_down 20
    text state_aid_text
    move_down 20
    text body_text2
  end

  def letterhead
    "EFG State Aid Letter to be sent to each borrower on lender's letterhead as part of loan Documentation"
  end

  def address
    text "Name", style: :bold
    move_down 10
    text "Address", style: :bold
    move_down 80
    text "Date", style: :bold
  end

  def title
    "Enterprise Finance Guarantee - Notification of State Aid"
  end

  # inline_format option allows inline HTML styling
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
  end

  def state_aid_text
    "I can confirm that the value of de minimis State Aid arising from this facility is #{@loan.state_aid} Euro."
  end

  def body_text1
    "Dear

    I am writing to provide you with the value of the State Aid applicable to the loan you have been offered through the Enterprise Finance Guarantee (EFG) should you accept it.

    The assistance provided through EFG, like many Government-backed business support schemes, is regarded as a State Aid and is governed according to the European Commission's “De Minimis” State Aid rules. Under these rules the maximum State Aid any business or individual may receive over any rolling three-year period is currently 200,000 Euro. This letter is sent in accordance with European Commission Notice on State Aid in the form of Guarantees, OJ C155 of 20 June 2008."
  end

  def body_text2
    "It is your responsibility to retain records of any State Aid arising from assistance received for a minimum of three years from the date of receipt and to ensure that you do not exceed the rolling three-year limit. If you make any other application for assistance during the next three years you should expect to be asked by the provider of that assistance about the State Aid you have already received.

    Please note that this letter is issued solely to advise you of the value of State Aid arising from your loan and is not a notice of further funding.

    Yours sincerely,"
  end

  def method_missing(method, *args, &block)
    @pdf.send(method, *args, &block)
  end

end