class PercentageInput < SimpleForm::Inputs::StringInput
  def input
    unit = '%'

    input_html_options[:maxlength] = 6
    input_html_options[:placeholder] = '0.0'
    input_html_options[:value] = @builder.object.send(attribute_name)

    template.content_tag(:div, class: 'input-append') do
      @builder.text_field(attribute_name, input_html_options) +
      template.content_tag(:span, unit, class: 'add-on')
    end
  end
end
