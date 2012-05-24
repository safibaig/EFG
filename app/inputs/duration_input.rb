class DurationInput < SimpleForm::Inputs::Base
  def input
    duration = @builder.object.send(attribute_name)

    template.content_tag(:div, class: 'input-append') do
      @builder.fields_for(attribute_name, duration) do |duration_fields|
        duration_fields.text_field(:years, input_html_options) + add_on('years') + ' ' +
        duration_fields.text_field(:months, input_html_options) + add_on('months')
      end
    end
  end

  private
  def add_on(name)
    name = ERB::Util.html_escape(name)
    %Q{<span class="add-on">#{name}</span>}.html_safe
  end
end
