class LenderUserAssociationImporter
  def self.import
    progress_bar = ProgressBar.new('Lender User Association', Lender.count())

    Lender.all.each.with_index do |lender, index|
      lender.created_by  = User.find_by_username!(lender.created_by_legacy_id)  if lender.created_by_legacy_id.present?
      lender.modified_by = User.find_by_username!(lender.modified_by_legacy_id) if lender.modified_by_legacy_id.present?
      lender.save!

      progress_bar.set(index)
    end

    progress_bar.finish
  end
end
