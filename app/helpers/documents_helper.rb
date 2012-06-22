module DocumentsHelper

  def state_aid_letter_link(loan)
    link_to 'Generate State Aid Letter', state_aid_letter_document_path(@loan, :format => :pdf), class: 'btn btn-info'
  end

end
