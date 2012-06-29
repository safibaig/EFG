# encoding: utf-8
class StateAidInput < CurrencyInput
  def input
    options[:unit] = '€'
    input_html_options[:disabled] = true

    super + @builder.button(:submit, 'State Aid Calculation', class: 'btn-info')
  end
end
