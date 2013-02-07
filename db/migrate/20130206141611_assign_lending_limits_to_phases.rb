class AssignLendingLimitsToPhases < ActiveRecord::Migration
  def up
    phase1 = Phase.find_by_name('Phase 1')
    phase2 = Phase.find_by_name('Phase 2')
    phase3 = Phase.find_by_name('Phase 3')
    phase4 = Phase.find_by_name('Phase 4')

    mapping = {
      'EFG Base FY 2009/10' => phase1,
      'FY 2009/10 CDFI A' => phase1,
      'Base 2008/09' => phase1,
      'SFLG Transfer 2009/10' => phase1,
      'Transfer 2008/09' => phase1,
      'Corporate EFG Base FY 2010/11' => phase2,
      'EFG Base FY 2010/11' => phase2,
      'EFG Extended FY 2010/11 Limit' => phase2,
      'SFLG Transfer FY 2010/11' => phase2,
      'SFLG Transfer FY 2011/12' => phase3,
      'Corporate EFG Base FY 2011/12' => phase3,
      'EFG Base FY 2011/12' => phase3,
      'EFG Extended FY 2012/13 Limit' => phase4,
      'SFLG Transfer FY 2012/13' => phase4,
      'Corporate EFG Base FY 2012/13' => phase4,
      'EFG Base FY 2012/13' => phase4
    }

    mapping.each do |lending_limit_name, phase|
      lending_limits = LendingLimit.where(name: lending_limit_name).update_all(phase_id: phase.id)
    end
  end

  def down
  end
end
