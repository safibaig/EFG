class QuickDateInput < SimpleForm::Inputs::Base
  def input
    date = @builder.object.send(attribute_name)

    template.content_tag(:div, class: 'input-append') do
      @builder.text_field(attribute_name,
        placeholder: 'dd/mm/yyyy',
        value: date && date.strftime('%d/%m/%Y')
      ) + icon
    end
  end

  private
  def icon
    %Q{<span class="add-on"><i class="icon-calendar"></i></span>}.html_safe
  end
end
