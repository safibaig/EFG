# encoding: utf-8

class InformationDeclaration < Prawn::Document

  attr_reader :filename

  def initialize(loan, pdf_opts = {})
    super(pdf_opts)
    @loan = loan
    @filename = "information_declaration_#{loan.reference}.pdf"
    self.font_size = 14
    build
  end

  private

  def build
    header

    bounding_box([bounds.left, bounds.top - 100], width: bounds.width, height: bounds.height - 100) do
      loan_details
      declaration
      declaration_important
      signatures
      signatories
    end

    footer
  end

  def header
    repeat :all do
      bounding_box [bounds.left, bounds.top], width: bounds.width do
        font_size 12

        stroke_horizontal_rule
        move_down 10

        text "Information Declaration", size: 15, style: :bold, align: :center

        data = [
          ["Lender organisation:", @loan.lender.name, "Business name:", @loan.business_name || '<undefined>'],
          ["SFLG reference number:", @loan.reference, "Loan amount:", @loan.amount.format]
        ]

        table(data, column_widths: [150, 140, 100, 150]) do
          cells.borders = []
        end

        move_down 10
        stroke_horizontal_rule
      end
    end
  end

  def footer
    number_pages("Page: <page> of <total>", at: [bounds.right - 550, 0], align: :center, size: 10)
  end

  def loan_details
    data = [
      [ "Item", "Value"],
      [ row_description(:reference), @loan.reference ],
      [ row_description(:business_name), @loan.business_name ],
      [ row_description(:trading_name), @loan.trading_name ],
      [ row_description(:legal_form_id), @loan.legal_form.try(:name) ],
      [ row_description(:company_registration), @loan.company_registration ],
      [ row_description(:turnover), @loan.turnover.try(:format) ],
      [ row_description(:trading_date), @loan.trading_date.try(:strftime, '%d-%m-%Y') ],
      [ row_description(:postcode), @loan.postcode ],
      [ row_description(:non_validated_postcode), @loan.non_validated_postcode ],
      [ row_description(:town), @loan.town ],
      [ row_description(:amount), @loan.amount.try(:format) ],
      [ row_description(:repayment_duration), @loan.repayment_duration.try(:format) ],
      [ row_description(:repayment_frequency_id), @loan.repayment_frequency.try(:name) ],
      [ row_description(:maturity_date), @loan.maturity_date.try(:strftime, '%d-%m-%Y') ],
      [ row_description(:sic_code), @loan.sic_code ],
      [ row_description(:sic_desc), @loan.sic_desc ],
      [ row_description(:loan_category_id), @loan.loan_category.try(:name) ],
      [ row_description(:reason_id), @loan.reason.try(:name) ],
      [ row_description(:previous_borrowing), @loan.previous_borrowing? ? "Yes" : "No" ],
      [ row_description(:state_aid), @loan.state_aid.try(:format) ],
      [ row_description(:state_aid_is_valid), @loan.state_aid_is_valid? ? "Yes" : "No" ]
    ]

    table(data, column_widths: [400, 140]) do
      cells.borders = []
      row(0).font_style = :bold
    end

    move_down 20

    stroke_horizontal_rule

    move_down 20
  end

  def row_description(key)
    I18n.t("simple_form.labels.loan_entry.#{key}")
  end

  def declaration
    text "Information Declaration", style: :bold, size: 15
    move_down 20

    text I18n.t('pdfs.information_declaration.declaration')
    move_down 20

    indent 20 do
      text I18n.t('pdfs.information_declaration.declaration_list')
    end

    move_down 20
  end

  def declaration_important
    text I18n.t('pdfs.information_declaration.declaration_important'), inline_format: true
  end

  def signatures
    move_down 20

    line = "_________________________"

    4.times do |num|
      data = [
        ["Signed", line],
        ["Print name", line],
        ["Position", line],
        ["Date", line]
      ]

      table(data) do
        cells.borders = []
      end

      move_down (num == 3 ? 20 : 50)
    end
  end

  def signatories
    text I18n.t('pdfs.information_declaration.signatories')
  end

end