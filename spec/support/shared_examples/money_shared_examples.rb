shared_examples_for "money attribute" do

  # expects #record and #money_attribute to be defined
  # #currency can be optionally defined to customise the currency
  it "should support large value" do
    chosen_currency = defined?(currency) ? currency : 'GBP'
    record.send("#{money_attribute}=", Money.new(40_000_000_00, chosen_currency))
    record.save(validate: false)

    record.reload
    record.send(money_attribute).should eq(Money.new(40_000_000_00, chosen_currency)), "#{money_attribute} does not equal 40 million"
  end

end
