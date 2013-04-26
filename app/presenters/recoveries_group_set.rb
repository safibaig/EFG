# encoding: utf-8

require 'group_set'

class RecoveriesGroupSet < GroupSet
  class RecoveriesGroup < GroupSet::Group
    def recoveries
      objects
    end
  end

  def self.group
    RecoveriesGroup
  end

  def initialize
    super
    add('Legacy SFLG Loans') {|recovery| recovery.loan.legacy_loan? }
    add('SFLG Loans') {|recovery| recovery.loan.sflg? }

    Phase.order('name ASC').each do |phase|
      # Compare ids here to avoid doing an extra join.
      add("EFG Loans – #{phase.name}") {|recovery| recovery.loan.efg_loan? && recovery.loan.lending_limit.phase_id = phase.id }
    end

    add('EFG Loans – Unknown Phase') {|recovery| recovery.loan.efg_loan? }
  end
end
