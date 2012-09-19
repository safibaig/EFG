module SearchHelper
  def search_sort_options
    Search::SortableAttributes.map do |attribute|
      [ I18n.t("sort_#{attribute}", scope: [:simple_form, :labels, :search]), attribute ]
    end
  end

  def search_lender_id_input(form_builder, search)
    if search.lender_user?
      form_builder.input :lender_id, as: :hidden, input_html: { value: current_user.lender.id }
    else
      form_builder.input :lender_id, as: :select, collection: search.allowed_lenders.order_by_name, prompt: 'All'
    end
  end
end
