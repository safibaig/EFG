module DocumentsHelper
  def link_to_state_aid_letter(loan)
    link_to 'Generate State Aid Letter', state_aid_letter_document_path(@loan, format: :pdf), class: 'btn btn-info'
  end
end
