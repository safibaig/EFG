# encoding: utf-8

module ApplicationHelper
  def breadcrumbs(*items)
    items.unshift(link_to('Home', root_path))
    divider = content_tag(:span, '/', class: 'divider')
    lis = []

    items.each_with_index do |item, index|
      lis << content_tag(:li, item + divider)
    end

    content_tag :ul, lis.join('').html_safe, class: 'breadcrumb'
  end

  def breadcrumbs_for_loan(loan, *extras)
    breadcrumbs(*[
      link_to('Loan Portfolio', loan_states_path),
      link_to("Loan #{loan.reference}", loan_path(loan))
    ])
  end

  def friendly_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def current_user_access_restricted?
    current_user.disabled? || current_user.locked?
  end

  def google_analytics
    return unless Rails.env.production?

    account, domain = Plek.current.environment == "preview" ?
      ['UA-34504094-2', 'preview.alphagov.co.uk'] :
      ['UA-34504094-1', 'production.alphagov.co.uk']

    %Q(<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '#{account}']);
  _gaq.push(['_setDomainName', '#{domain}']);
  _gaq.push(['_setSiteSpeedSampleRate', 100]);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>).html_safe
  end

  def simple_form_row(label, control)
    content_tag :div, class: 'control-group' do
      content_tag(:div, label, class: 'control-label') +
        content_tag(:div, control, class: 'controls')
    end
  end

  def application_title
    return 'Enterprise Finance Guarantee – Training' if training_mode?
    'Enterprise Finance Guarantee'
  end

  def training_mode?
    EFG::Application.config.training_mode
  end
end
