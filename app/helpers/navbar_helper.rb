module NavbarHelper
  def navbar(type = :primary, &content)
    classes = ['navbar']
    case type
    when :primary
      classes << 'navbar-primary navbar-inverse'
    when :secondary
      classes << 'navbar-secondary'
    end

    content_tag(:div, class: classes) do
      content_tag(:div, class: 'navbar-inner') do
        content_tag(:div, class: 'container', &content)
      end
    end
  end

  def navbar_title(title, path)
    link_to title, path, class: 'brand'
  end

  def navigation(direction = nil, &navigation)
    raise ArgumentError, "unknown direction :#{direction}" if direction && direction != :right

    classes = ['nav']
    classes << 'pull-right' if direction == :right

    content = capture(Navigation.new(self), &navigation)
    content_tag(:ul, content, class: classes)
  end

  private
  class Navigation < ActionView::Base
    def initialize(helper = nil)
      @helper = helper || self
    end

    attr_reader :helper

    def item(name, path = '', options = {})
      link = link_to(name, path, options)
      content_tag(:li, link)
    end

    def dropdown(name, &dropdown)
      content_tag(:li, class: 'dropdown') do
        name = ERB::Util.html_escape(name)
        link_text = name.concat(%Q{ <b class="caret"></b>}.html_safe)

        link = link_to(name, '#', 'class' => 'dropdown-toggle', 'data-toggle' => 'dropdown')
        content = helper.capture(Dropdown.new, &dropdown)
        dropdown = content_tag(:ul, content, class: 'dropdown-menu')
        link + dropdown
      end
    end

    def divider
      content_tag(:li, '', class: 'divider-vertical')
    end
  end

  class Dropdown < ActionView::Base
    def item(name, path = '', options = {})
      link = link_to(name, path, options)
      content_tag(:li, link)
    end

    def divider
      content_tag(:li, '', class: 'divider')
    end
  end
end
