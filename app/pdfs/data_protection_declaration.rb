# encoding: utf-8
class DataProtectionDeclaration < Prawn::Document

  attr_reader :filename

  def initialize(pdf_opts = {})
    super(pdf_opts)
    @filename = "data_protection_declaration.pdf"
    self.font_size = 14
    build
  end

  private

  def build
    title
    declaration
    signatures
    signatories
  end

  def title
    text I18n.t('pdfs.data_protection.title').upcase, size: 15, style: :bold
    move_down 20
  end

  def declaration
    text I18n.t('pdfs.data_protection.declaration')
    move_down 20

    indent 20 do
      text I18n.t('pdfs.data_protection.declaration_list')
    end
    move_down 20
  end

  def signatures
    move_down 20
    text "Signature Section", size: 15, style: :bold
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

      move_down 30
      stroke_horizontal_rule unless num == 3
      move_down 30
    end
  end

  def signatories
    text I18n.t('pdfs.data_protection.signatories')
    move_down 20
  end

end