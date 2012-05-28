require 'spec_helper'

describe LoanPresenter do
  let(:klass) do
    Class.new do
      include LoanPresenter

      attribute :name
      attribute :town, read_only: true
    end
  end

  let(:loan) { double(Loan) }
  let(:transition) { klass.new(loan) }

  describe "ActiveModel conformance" do
    it "persisted? should be false" do
      transition.should_not be_persisted
    end

    it "should include ActiveModel::Conversion" do
      klass.ancestors.should include(ActiveModel::Conversion)
    end

    it "should extend ActiveModel::Naming" do
      klass.singleton_class.ancestors.should include(ActiveModel::Naming)
    end
  end

  describe "#initialize" do
    it "should take a loan" do
      transition = klass.new(loan)
      transition.loan.should == loan
    end
  end

  describe "attribute delegation" do
    context "read write attributes" do
      it "should delegate the reader to the loan" do
        loan.should_receive(:name).and_return('Name')

        transition.name.should == 'Name'
      end

      it "should delegate the writer to the loan" do
        loan.should_receive(:name=).with('NewName')

        transition.name = 'NewName'
      end
    end

    context "read only attribute" do
      it "should not have a writer" do
        transition.should_not respond_to(:town=)
      end
    end
  end

  describe "#attributes=" do
    it "should call the writers for defined attributes" do
      transition.should_receive(:name=).with('Name')

      transition.attributes = {'name' => 'Name'}
    end

    it "should not call methods for read only attributes" do
      transition.should_not_receive(:town=)

      transition.attributes = {'town' => 'Town'}
    end

    it "should not call methods for undefined attributes" do
      transition.should_not_receive(:junk=)

      transition.attributes = {'junk' => 'junk'}
    end
  end

  describe "#save" do
    it "should delegate to loan" do
      loan.should_receive(:save).and_return(true)

      transition.save.should == true
    end
  end
end
