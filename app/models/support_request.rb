class SupportRequest

  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :message

  validates_presence_of :message

  def initialize(attributes = {})
    @message = attributes[:message]
  end

  def persisted?
    false
  end

end
