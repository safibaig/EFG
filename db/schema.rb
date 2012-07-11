# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120710142606) do

  create_table "invoices", :force => true do |t|
    t.integer  "lender_id"
    t.string   "reference"
    t.string   "period_covered_quarter"
    t.string   "period_covered_year"
    t.date     "received_on"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lenders", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "legacy_id"
    t.integer  "version"
    t.boolean  "high_volume"
    t.boolean  "can_use_add_cap"
    t.string   "organisation_reference_code"
    t.string   "primary_contact_name"
    t.string   "primary_contact_phone"
    t.string   "primary_contact_email"
    t.integer  "std_cap_lending_allocation"
    t.integer  "add_cap_lending_allocation"
    t.boolean  "disabled"
    t.string   "created_by"
    t.string   "modified_by"
    t.boolean  "allow_alert_process"
    t.string   "main_point_of_contact_user"
    t.string   "loan_scheme"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
  end

  add_index "lenders", ["legacy_id"], :name => "index_lenders_on_legacy_id", :unique => true

  create_table "loan_allocations", :force => true do |t|
    t.integer  "lender_id"
    t.integer  "legacy_id"
    t.integer  "lender_legacy_id"
    t.integer  "version"
    t.integer  "allocation_type"
    t.boolean  "active"
    t.integer  "allocation"
    t.date     "starts_on"
    t.date     "ends_on"
    t.string   "description"
    t.string   "modified_by_legacy_id"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.decimal  "premium_rate",          :precision => 16, :scale => 2
    t.decimal  "guarantee_rate",        :precision => 16, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "loan_allocations", ["lender_id"], :name => "index_loan_allocations_on_lender_id"

  create_table "loan_realisations", :force => true do |t|
    t.integer  "realised_loan_id"
    t.integer  "realisation_statement_id"
    t.integer  "created_by_id"
    t.integer  "realised_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "loan_realisations", ["created_by_id"], :name => "index_loan_realisations_on_created_by_id"
  add_index "loan_realisations", ["realisation_statement_id"], :name => "index_loan_realisations_on_realisation_statement_id"
  add_index "loan_realisations", ["realised_loan_id"], :name => "index_loan_realisations_on_realised_loan_id"

  create_table "loans", :force => true do |t|
    t.boolean  "viable_proposition",                                                               :null => false
    t.boolean  "would_you_lend",                                                                   :null => false
    t.boolean  "collateral_exhausted",                                                             :null => false
    t.integer  "amount",                                                                           :null => false
    t.integer  "lender_cap_id"
    t.integer  "repayment_duration",                                                               :null => false
    t.integer  "turnover"
    t.date     "trading_date"
    t.string   "sic_code",                                                                         :null => false
    t.integer  "loan_category_id"
    t.integer  "reason_id"
    t.boolean  "previous_borrowing",                                                               :null => false
    t.boolean  "private_residence_charge_required"
    t.boolean  "personal_guarantee_required"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lender_id",                                                                        :null => false
    t.boolean  "declaration_signed"
    t.string   "business_name"
    t.string   "trading_name"
    t.string   "company_registration"
    t.string   "postcode"
    t.string   "non_validated_postcode"
    t.string   "branch_sortcode"
    t.string   "generic1"
    t.string   "generic2"
    t.string   "generic3"
    t.string   "generic4"
    t.string   "generic5"
    t.string   "town"
    t.integer  "interest_rate_type_id"
    t.decimal  "interest_rate",                                     :precision => 5,  :scale => 2
    t.integer  "fees"
    t.boolean  "state_aid_is_valid"
    t.boolean  "facility_letter_sent"
    t.date     "facility_letter_date"
    t.boolean  "received_declaration"
    t.boolean  "signed_direct_debit_received"
    t.boolean  "first_pp_received"
    t.date     "initial_draw_date"
    t.integer  "initial_draw_value"
    t.date     "maturity_date"
    t.string   "state"
    t.integer  "legal_form_id"
    t.integer  "repayment_frequency_id"
    t.date     "cancelled_on"
    t.integer  "cancelled_reason_id"
    t.text     "cancelled_comment"
    t.date     "borrower_demanded_on"
    t.integer  "borrower_demanded_amount"
    t.date     "repaid_on"
    t.date     "no_claim_on"
    t.date     "dti_demanded_on"
    t.integer  "dti_demand_outstanding"
    t.text     "dti_reason"
    t.string   "dti_ded_code"
    t.integer  "legacy_id"
    t.string   "reference"
    t.string   "created_by_legacy_id"
    t.integer  "version"
    t.date     "guaranteed_on"
    t.string   "modified_by_legacy_id"
    t.integer  "lender_legacy_id"
    t.integer  "outstanding_amount"
    t.boolean  "standard_cap"
    t.integer  "next_change_history_seq"
    t.integer  "borrower_demand_outstanding"
    t.date     "realised_money_date"
    t.integer  "event_legacy_id"
    t.integer  "state_aid"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.boolean  "notified_aid"
    t.integer  "remove_guarantee_outstanding_amount"
    t.date     "remove_guarantee_on"
    t.string   "remove_guarantee_reason"
    t.integer  "dti_amount_claimed"
    t.integer  "invoice_legacy_id"
    t.date     "settled_on"
    t.integer  "next_borrower_demand_seq"
    t.string   "sic_desc"
    t.string   "sic_parent_desc"
    t.boolean  "sic_notified_aid"
    t.boolean  "sic_eligible"
    t.string   "non_val_postcode",                    :limit => 10
    t.integer  "transferred_from"
    t.integer  "next_in_calc_seq"
    t.string   "loan_source",                         :limit => 1
    t.integer  "dit_break_costs"
    t.decimal  "guarantee_rate",                                    :precision => 16, :scale => 2
    t.decimal  "premium_rate",                                      :precision => 16, :scale => 2
    t.boolean  "legacy_small_loan"
    t.integer  "next_in_realise_seq"
    t.integer  "next_in_recover_seq"
    t.date     "recovery_on"
    t.integer  "recovery_statement_legacy_id"
    t.integer  "dti_interest"
    t.string   "loan_scheme",                         :limit => 1
    t.integer  "business_type"
    t.integer  "payment_period"
    t.decimal  "security_proportion",                               :precision => 5,  :scale => 2
    t.decimal  "current_refinanced_value",                          :precision => 16, :scale => 2
    t.decimal  "final_refinanced_value",                            :precision => 16, :scale => 2
    t.decimal  "original_overdraft_proportion",                     :precision => 5,  :scale => 2
    t.decimal  "refinance_security_proportion",                     :precision => 5,  :scale => 2
    t.integer  "overdraft_limit"
    t.boolean  "overdraft_maintained"
    t.integer  "invoice_discount_limit"
    t.decimal  "debtor_book_coverage",                              :precision => 5,  :scale => 2
    t.decimal  "debtor_book_topup",                                 :precision => 5,  :scale => 2
    t.integer  "loan_allocation_id"
    t.integer  "invoice_id"
  end

  add_index "loans", ["lender_id"], :name => "index_loans_on_lender_id"
  add_index "loans", ["loan_allocation_id"], :name => "index_loans_on_loan_allocation_id"
  add_index "loans", ["state"], :name => "index_loans_on_state"

  create_table "realisation_statements", :force => true do |t|
    t.integer  "lender_id"
    t.integer  "created_by_id"
    t.string   "reference"
    t.string   "period_covered_quarter"
    t.string   "period_covered_year"
    t.date     "received_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "state_aid_calculations", :force => true do |t|
    t.integer  "loan_id",                                                           :null => false
    t.integer  "initial_draw_year"
    t.integer  "initial_draw_amount",                                               :null => false
    t.integer  "initial_draw_months"
    t.integer  "initial_capital_repayment_holiday"
    t.integer  "second_draw_amount"
    t.integer  "second_draw_months"
    t.integer  "third_draw_amount"
    t.integer  "third_draw_months"
    t.integer  "fourth_draw_amount"
    t.integer  "fourth_draw_months"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "legacy_loan_id"
    t.integer  "seq"
    t.integer  "loan_version"
    t.string   "calc_type"
    t.string   "premium_cheque_month"
    t.integer  "holiday"
    t.integer  "total_cost"
    t.integer  "public_funding"
    t.boolean  "obj1_area"
    t.boolean  "reduce_costs"
    t.boolean  "improve_prod"
    t.boolean  "increase_quality"
    t.boolean  "improve_nat_env"
    t.boolean  "promote"
    t.boolean  "agriculture"
    t.integer  "guarantee_rate"
    t.decimal  "npv",                               :precision => 2,  :scale => 1
    t.decimal  "prem_rate",                         :precision => 2,  :scale => 1
    t.decimal  "euro_conv_rate",                    :precision => 17, :scale => 14
    t.integer  "elsewhere_perc"
    t.integer  "obj1_perc"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
  end

  add_index "state_aid_calculations", ["legacy_loan_id"], :name => "index_state_aid_calculations_on_legacy_loan_id"
  add_index "state_aid_calculations", ["loan_id"], :name => "index_state_aid_calculations_on_loan_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",                    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lender_id"
    t.integer  "legacy_lender_id"
    t.integer  "version"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "disabled"
    t.string   "memorable_name"
    t.string   "memorable_place"
    t.string   "memorable_year"
    t.integer  "login_failures"
    t.datetime "password_changed_at"
    t.boolean  "locked"
    t.string   "created_by_legacy_id"
    t.integer  "created_by_id"
    t.boolean  "confirm_t_and_c"
    t.string   "modified_by_legacy_id"
    t.integer  "modified_by_id"
    t.boolean  "knowledge_resource"
    t.string   "legacy_id"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.string   "type"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["legacy_id"], :name => "index_users_on_legacy_id", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["type"], :name => "index_users_on_type"

end
