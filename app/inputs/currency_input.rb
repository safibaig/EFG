# encoding: utf-8

class CurrencyInput < SimpleForm::Inputs::StringInput
  def input
    unit = options[:unit] || '£'

    input_html_options[:value] = @builder.object.send(attribute_name)

    template.content_tag(:div, class: 'input-prepend') do
      template.content_tag(:span, unit, class: 'add-on') + super
    end
  end
end
