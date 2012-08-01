class QuickDateInput < SimpleForm::Inputs::Base
  def input
    date = @builder.object.send(attribute_name)

    input_html_options[:placeholder] = 'dd/mm/yyyy'
    input_html_options[:value] = date.is_a?(Date) ? date && date.strftime('%d/%m/%Y') : date

    template.content_tag(:div, class: 'input-append') do
      @builder.text_field(attribute_name, input_html_options) + icon
    end
  end

  private
  def icon
    %Q{<span class="add-on"><i class="icon-calendar"></i></span>}.html_safe
  end
end
