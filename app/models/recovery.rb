class Recovery < ActiveRecord::Base
  include FormatterConcern

  belongs_to :loan
  belongs_to :created_by, class_name: 'LenderUser'

  validates_presence_of :loan, :created_by, :recovered_on

  format :recovered_on, with: QuickDateFormatter
end
