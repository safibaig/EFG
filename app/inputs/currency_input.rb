# encoding: utf-8

class CurrencyInput < SimpleForm::Inputs::StringInput
  def input
    template.content_tag(:div, class: 'input-prepend') do
      template.content_tag(:span, '£', class: 'add-on') + super
    end
  end
end
