class Phase < ActiveRecord::Base
  validates_presence_of :name, strict: true
end
