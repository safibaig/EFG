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

ActiveRecord::Schema.define(:version => 20120517155611) do

  create_table "loans", :force => true do |t|
    t.boolean  "viable_proposition",                :null => false
    t.boolean  "would_you_lend",                    :null => false
    t.boolean  "collateral_exhausted",              :null => false
    t.integer  "amount",                            :null => false
    t.integer  "lender_cap",                        :null => false
    t.integer  "repayment_duration",                :null => false
    t.integer  "turnover",                          :null => false
    t.date     "trading_date",                      :null => false
    t.string   "sic_code",                          :null => false
    t.integer  "loan_category",                     :null => false
    t.integer  "reason",                            :null => false
    t.boolean  "previous_borrowing",                :null => false
    t.boolean  "private_residence_charge_required", :null => false
    t.boolean  "personal_guarantee_required",       :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

end
