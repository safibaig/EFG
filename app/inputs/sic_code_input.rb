class SICCodeInput < SimpleForm::Inputs::Base
  def input
    template.content_tag(:div, class: 'input-append') do
      @builder.text_field(attribute_name, input_html_options) + icon
    end
  end

  private
  def icon
    %Q{<span class="add-on"><i class="icon-search"></i></span>}.html_safe
  end
end

SicCodeInput = SICCodeInput
