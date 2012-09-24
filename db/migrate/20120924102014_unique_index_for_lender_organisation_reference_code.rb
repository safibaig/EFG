class UniqueIndexForLenderOrganisationReferenceCode < ActiveRecord::Migration
  def up
    add_index :lenders, :organisation_reference_code, unique: true
  end

  def down
    remove_index :lenders, :organisation_reference_code
  end
end
