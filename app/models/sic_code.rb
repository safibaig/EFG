class SicCode < ActiveRecord::Base
  attr_accessible :code, :description, :eligible, :public_sector_restricted

  validates_presence_of :code, :description
  validates_inclusion_of :eligible, in: [true, false]
  validates_inclusion_of :public_sector_restricted, in: [true, false]
end
