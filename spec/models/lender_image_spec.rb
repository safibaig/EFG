require 'spec_helper'

describe LenderLogo do
  let(:logo) { LenderLogo.new('XX') }

  describe '#public_path' do
    it 'returns the correct path' do
      logo.public_path.should == '/system/logos/XX.jpg'
    end
  end

  describe '#exists?' do
    context 'when the image does not exist on disk' do
      it 'returns false' do
        logo.stub_chain(:path, :exist?).and_return false
        logo.exists?.should be_false
      end
    end

    context 'when the image does exist on disk' do
      it 'returns true' do
        logo.stub_chain(:path, :exist?).and_return true
        logo.exists?.should be_true
      end
    end
  end
end
