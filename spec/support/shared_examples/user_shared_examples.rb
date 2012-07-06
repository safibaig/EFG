shared_examples_for 'User' do
  describe 'validations' do
    it 'should have a valid factory' do
      user.should be_valid
    end

    it 'should require a first_name' do
      user.first_name = ''
      user.should_not be_valid
    end

    it 'should require a last_name' do
      user.last_name = ''
      user.should_not be_valid
    end
  end
end
