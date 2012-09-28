class Expert < ActiveRecord::Base
  belongs_to :lender
  belongs_to :user

  before_validation :set_lender_id

  validates_presence_of :lender_id, strict: true
  validates_presence_of :user, strict: true
  validates_uniqueness_of :user_id

  private
    def set_lender_id
      self.lender_id = user.try(:lender_id)
    end
end
