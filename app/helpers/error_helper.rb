module ErrorHelper

  def render_errors_on_base(errors)
    unless errors[:base].empty?
      content_tag(:ul, class: 'errors-on-base') do
        errors[:base].collect { |error| content_tag :li, error }.join.html_safe
      end
    end
  end

end
