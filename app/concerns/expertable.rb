module Expertable
  extend ActiveSupport::Concern

  included do
    has_one :expert, foreign_key: 'user_id'
  end

  def expert?
    !expert.nil?
  end
end
