class SicCode < ActiveRecord::Base
  attr_accessible :code, :description, :eligible, :public_sector_restricted

  validates_presence_of :code, :description
  validates_uniqueness_of :code
  validates_inclusion_of :eligible, in: [true, false]
  validates_inclusion_of :public_sector_restricted, in: [true, false]

  default_scope order(:code)
end
