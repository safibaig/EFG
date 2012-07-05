module DocumentsHelper
  def link_to_state_aid_letter(loan)
    return unless current_user.can_view?(StateAidLetter)
    link_to 'Generate State Aid Letter', state_aid_letter_document_path(@loan, format: :pdf), class: 'btn btn-info'
  end
end
