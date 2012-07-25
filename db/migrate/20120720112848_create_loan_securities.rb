class CreateLoanSecurities < ActiveRecord::Migration
  def change
    create_table :loan_securities do |t|
      t.integer :loan_id
      t.integer :loan_security_type_id

      t.timestamps
    end

    add_index :loan_securities, :loan_id
    add_index :loan_securities, :loan_security_type_id
  end
end
