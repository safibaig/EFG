class QuickDateInput < SimpleForm::Inputs::Base
  def input
    date = @builder.object.send(attribute_name)

    input_html_options[:placeholder] = 'dd/mm/yyyy'
    input_html_options[:value] = date && date.to_s(:screen)

    template.content_tag(:div, class: 'input-append') do
      @builder.text_field(attribute_name, input_html_options) + icon
    end
  end

  private
  def icon
    %Q{<span class="add-on"><i class="icon-calendar"></i></span>}.html_safe
  end
end
