class QuickDateInput < SimpleForm::Inputs::Base
  def input
    template.content_tag(:div, class: 'input-append') do
      @builder.text_field(attribute_name, placeholder: 'dd/mm/yyyy') + icon
    end
  end

  private
  def icon
    %Q{<span class="add-on"><i class="icon-calendar"></i></span>}.html_safe
  end
end
