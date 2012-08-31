class DedCode < ActiveRecord::Base

  validates_presence_of :group_description, :category_description, :code, :code_description

  attr_accessible :group_description, :category_description, :code, :code_description

end
