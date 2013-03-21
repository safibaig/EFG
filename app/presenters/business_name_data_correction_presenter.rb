class BusinessNameDataCorrectionPresenter < DataCorrectionPresenter
  attr_accessor :business_name
  attr_accessible :business_name

  validates :business_name, presence: true

  private
    def update_data_correction
      data_correction.change_type_id = ChangeType::BusinessName.id
      data_correction.business_name = business_name
      data_correction.old_business_name = loan.business_name
    end

    def update_loan
      loan.business_name = business_name
    end
end
