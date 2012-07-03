class ActiveRecord::Base
  # TODO: A proper ActiveRecord NullRelation or backport Rails 4's version.
  def self.none
    where('1=0')
  end
end
