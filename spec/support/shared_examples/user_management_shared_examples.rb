shared_examples_for 'an admin viewing active and disabled users' do
  it 'displays only active users by default' do
    page.should have_content(active_user.name)
    page.should_not have_content(disabled_user.name)
  end

  it 'clicking on the disabled tab displays only disabled users' do
    click_link 'Disabled'

    page.should_not have_content(active_user.name)
    page.should have_content(disabled_user.name)
  end
end

