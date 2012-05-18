class DurationInput < SimpleForm::Inputs::Base
  def input
    years = @builder.object.send(attribute_name)[:years]
    months = @builder.object.send(attribute_name)[:months]

    template.content_tag(:div, class: 'input-append') do
      template.text_field_tag(input_name('years'), years) + add_on('years') + ' ' +
      template.text_field_tag(input_name('months'), months) + add_on('months')
    end
  end

  private
  def input_name(name)
    "#{@builder.object_name}[#{attribute_name}][#{name}]"
  end

  def add_on(name)
    name = ERB::Util.html_escape(name)
    %Q{<span class="add-on">#{name}</span>}.html_safe
  end
end
