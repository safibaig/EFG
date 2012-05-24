# encoding: utf-8

class CurrencyInput < SimpleForm::Inputs::StringInput
  def input
    unit = options[:unit] || '£'

    template.content_tag(:div, class: 'input-prepend') do
      template.content_tag(:span, unit, class: 'add-on') + super
    end
  end
end
