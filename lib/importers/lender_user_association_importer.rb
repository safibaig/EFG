class LenderUserAssociationImporter
  def self.import
    Lender.all.each.with_index do |lender, index|
      if lender.created_by_legacy_id.present?
        lender.created_by = User.find_by_username!(lender.created_by_legacy_id)
      else
        lender.created_by = nil
        lender.created_by_id = -1
      end

      lender.modified_by = User.find_by_username!(lender.modified_by_legacy_id) if lender.modified_by_legacy_id.present?
      lender.save!

      progress_bar.try(:set, index)
    end

    progress_bar.try(:finish)
  end

  def self.progress_bar
    return nil if Rails.env.test?
    @progress_bar ||= ProgressBar.new('Lender User Association', Lender.count())
  end
end
