class LenderUser < User
  belongs_to :lender

  # FIXME: lender users should require a lender so require lender_id when we
  # come to implementing roles
end
