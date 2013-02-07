# encoding: utf-8

require 'group_set'

class LoanGroupSet < GroupSet
  class LoanGroup < GroupSet::Group
    def loans
      objects
    end
  end

  def self.group
    LoanGroup
  end

  def initialize
    super
    add('Legacy SFLG Loans') {|loan| loan.legacy_loan? }
    add('SFLG Loans') {|loan| loan.sflg? }

    Phase.order('name ASC').each do |phase|
      # Compare ids here to avoid doing an extra join.
      add("EFG Loans – #{phase.name}") {|loan| loan.efg_loan? && loan.lending_limit.phase_id = phase.id }
    end

    add('EFG Loans – Unknown Phase') {|loan| loan.efg_loan? }
  end
end
