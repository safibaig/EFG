ActiveRecord::Base.transaction do
  update_file = File.expand_path('../2012-11-23_import_fixes.yml', __FILE__)
  updates = YAML.load_file(update_file)

  updates.each do |attribute, ids|
    count = Loan.where(id: ids).where(attribute => 0).update_all(attribute => nil)
    puts "#{attribute.inspect} Update: #{count}"
  end

  transferred_loans = Loan.where('transferred_from_id IS NOT NULL').where("created_at >= '2012-10-20'").includes(:transferred_from)
  transferred_loans.each do |transferred_loan|
    transferred_from = transferred_loan.transferred_from
    transferred_loan.premium_rate = transferred_from.premium_rate
    transferred_loan.guarantee_rate = transferred_from.guarantee_rate
    transferred_loan.interest_rate = transferred_from.interest_rate
    transferred_loan.security_proportion = transferred_from.security_proportion
    transferred_loan.original_overdraft_proportion = transferred_from.original_overdraft_proportion
    transferred_loan.refinance_security_proportion = transferred_from.refinance_security_proportion
    transferred_loan.debtor_book_coverage = transferred_from.debtor_book_coverage
    transferred_loan.debtor_book_topup = transferred_from.debtor_book_topup
    transferred_loan.save!
  end

  puts "Transferred Loans Update: #{transferred_loans.count}"
end
