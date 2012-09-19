class UserRoleMapper

  class << self
    attr_accessor :user_roles_csv_path
  end

  self.user_roles_csv_path = Rails.root.join('import_data/SFLG_USER_ROLE_DATA_TABLE.csv')

  ROLE_MAPPING = {
    'btAdmin'      => 'SuperUser',
    'sflgAdmin'    => 'CfeAdmin',
    'sflgUser'     => 'CfeUser',
    'sflgRole1'    => 'CfeUser',
    'sflgRole2'    => 'CfeUser',
    'sflgRole4'    => 'CfeUser',
    'sflgRole5'    => 'CfeUser',
    'lenderAdmin'  => 'LenderAdmin',
    'sflgRole6'    => 'AuditorUser',
    'sflgRole7'    => 'PremiumCollectorUser',
    'lenderUser'   => 'LenderUser',
    'lenderRole1'  => 'LenderUser',
    'lenderRole2'  => 'LenderUser',
    'lenderRole3'  => 'LenderUser',
    'lenderRole4'  => 'LenderUser',
    'lenderRole5'  => 'LenderUser',
    'lenderRole6'  => 'LenderUser',
    'lenderRole7'  => 'LenderUser',
    'lenderRole8'  => 'LenderUser',
    'lenderRole9'  => 'LenderUser',
    'lenderRole10' => 'LenderUser',
    'lenderRole11' => 'LenderUser',
    'lenderRole12' => 'LenderUser',
    'lenderRole13' => 'LenderUser'
  }.freeze

  def initialize(user)
    @user = user
  end

  # LenderAdmin role, then LenderUser role take precedence over all other roles
  #
  #   user_role[0] = username
  #   user_role[1] = role name
  #
  def user_type
    user_roles = self.class.legacy_user_roles[@user.username]

    return 'LenderAdmin' if user_roles.include?('lenderAdmin')
    return 'LenderUser' if (user_roles & lender_user_legacy_roles).size > 0
    return ROLE_MAPPING[user_roles.last]
  end

  private

  # return hash of usernames with an array of all their roles:
  #   {
  #     <username> => [ <role_name>, <role_name> ],
  #     <username> => [ <role_name>, <role_name> ]
  #   }
  def self.legacy_user_roles
    @legacy_user_roles ||= begin
      csv_data = File.read(user_roles_csv_path)
      CSV.parse(csv_data, return_headers: false).inject({}) do |memo, (username, role_name)|
        memo[username] ||= []
        memo[username] << role_name
        memo
      end
    end
  end

  # returns array of all roles for a lender user
  # i.e. [ 'LenderUser', 'LenderRole1'..'LenderRole13' ]
  def lender_user_legacy_roles
    @lender_user_legacy_roles ||= ROLE_MAPPING.select { |key, value| value == 'LenderUser' }.keys
  end

end
