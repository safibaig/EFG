class QuickDateInput < SimpleForm::Inputs::Base
  def input
    date = @builder.object.send(attribute_name)

    input_html_options[:placeholder] = 'dd/mm/yyyy'
    input_html_options[:value] = date && date.to_s(:screen)

    template.content_tag(:div) do
      @builder.text_field(attribute_name, input_html_options)
    end
  end
end
