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

ActiveRecord::Schema.define(:version => 20120611104303) do

  create_table "lenders", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "loans", :force => true do |t|
    t.boolean  "viable_proposition",                                              :null => false
    t.boolean  "would_you_lend",                                                  :null => false
    t.boolean  "collateral_exhausted",                                            :null => false
    t.integer  "amount",                                                          :null => false
    t.integer  "lender_cap_id",                                                   :null => false
    t.integer  "repayment_duration",                                              :null => false
    t.integer  "turnover",                                                        :null => false
    t.date     "trading_date",                                                    :null => false
    t.string   "sic_code",                                                        :null => false
    t.integer  "loan_category_id",                                                :null => false
    t.integer  "reason_id",                                                       :null => false
    t.boolean  "previous_borrowing",                                              :null => false
    t.boolean  "private_residence_charge_required",                               :null => false
    t.boolean  "personal_guarantee_required",                                     :null => false
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.integer  "lender_id",                                                       :null => false
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
    t.decimal  "interest_rate",                     :precision => 5, :scale => 2
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
    t.integer  "cancelled_reason"
    t.text     "cancelled_comment"
    t.date     "borrower_demanded_on"
    t.integer  "borrower_demanded_amount"
    t.date     "repaid_on"
    t.date     "no_claim_on"
    t.date     "dti_demanded_on"
    t.integer  "dti_demand_outstanding"
    t.text     "dti_reason"
    t.string   "dti_ded_code"
  end

  add_index "loans", ["state"], :name => "index_loans_on_state"

  create_table "state_aid_calculations", :force => true do |t|
    t.integer  "loan_id",                           :null => false
    t.integer  "initial_draw_year",                 :null => false
    t.integer  "initial_draw_amount",               :null => false
    t.integer  "initial_draw_months",               :null => false
    t.integer  "initial_capital_repayment_holiday"
    t.integer  "second_draw_amount"
    t.integer  "second_draw_months"
    t.integer  "third_draw_amount"
    t.integer  "third_draw_months"
    t.integer  "fourth_draw_amount"
    t.integer  "fourth_draw_months"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "state_aid_calculations", ["loan_id"], :name => "index_state_aid_calculations_on_loan_id"

  create_table "users", :force => true do |t|
    t.string   "name",                                  :null => false
    t.string   "email",                                 :null => false
    t.string   "encrypted_password",                    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "lender_id",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
