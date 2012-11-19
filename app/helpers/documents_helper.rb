module DocumentsHelper
  def link_to_state_aid_letter(loan)
    return unless current_user.can_view?(StateAidLetter)
    link_to 'Generate State Aid Letter', state_aid_letter_document_path(@loan, format: :pdf), class: 'btn btn-info pdf-download'
  end

  def link_to_information_declaration(loan)
    return unless current_user.can_view?(InformationDeclaration)
    link_to 'View Information Declaration', information_declaration_document_path(@loan, format: :pdf), class: 'btn btn-info pdf-download'
  end
end
