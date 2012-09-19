require 'csv'
require 'importers/user_role_mapper'

namespace :export do

  desc "Combine user, lender & user role CSVs into a new CSV"
  task :combined_user_data do
    lender_csv_path    = "import_data/SFLG_LENDER_DATA_TABLE.csv"
    user_csv_path      = "import_data/SFLG_USER_DATA_TABLE.csv"
    user_role_csv_path = "import_data/SFLG_USER_ROLE_DATA_TABLE.csv"
    export_path        = "combined_user_data.csv"
    role_mapping       = UserRoleMapper::ROLE_MAPPING
    lenders            = {}
    user_roles         = {}

    CSV.foreach(lender_csv_path, headers: true) do |row|
      lenders[row['OID']] = row['NAME']
    end

    CSV.foreach(user_role_csv_path, headers: true) do |row|
      next if row['ROLE'] == 'user'

      user_id = row['USER_ID']
      mapped_role = role_mapping[row['ROLE']]
      user_roles[user_id] ||= []
      unless user_roles[user_id].include?(mapped_role)
        user_roles[user_id] << mapped_role
      end
    end

    CSV.open(export_path, 'w') do |csv|
      csv << ["Username", "First Name", "Last Name", "Email", "Lender", "Role(s)", "Last Login", "Disabled"]

      CSV.foreach(user_csv_path, headers: true) do |row|
        csv << [
          row['USER_ID'],
          row['FIRST_NAME'],
          row['LAST_NAME'],
          row['EMAIL_ADDRESS'],
          lenders[row['LENDER_OID']],
          user_roles[row['USER_ID']].join(", "),
          row["LAST_LOGIN_TIME"],
          row['DISABLED'] == "1" ? "Yes" : "No"
        ]
      end

    end
  end

end
