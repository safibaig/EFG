# This is intended to provide a mechanism by which relatively expensive data
# updates can be decoupled from deployment time and run independently.
#
# This will execute within an ActiveRecord transaction and is instance_eval-ed.
# Just write normal ruby code and refer to any model objects that you require.
# Since a data migration is intended to be run in production, when the schema
# and model are known quantities, it should be fine to reference model classes
# directly, even though in the future they may be refactored or deleted
# entirely.

loans = Loan.where('transferred_from_id IS NOT NULL').where(state: [Loan::Incomplete, Loan::Completed, Loan::Offered]).includes(:initial_draw_change)
loans.find_each do |loan|
  loan.initial_draw_change.try(:delete)
end
