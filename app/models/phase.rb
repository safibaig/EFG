class Phase < ActiveRecord::Base
  belongs_to :created_by, class_name: 'User'
  belongs_to :modified_by, class_name: 'User'

  validates_presence_of :name
  validates_presence_of :created_by, strict: true
  validates_presence_of :modified_by, strict: true
end
