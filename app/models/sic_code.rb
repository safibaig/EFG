class SicCode < ActiveRecord::Base
  attr_accessible :code, :description, :eligible

  validates_presence_of :code, :description, :eligible
end
