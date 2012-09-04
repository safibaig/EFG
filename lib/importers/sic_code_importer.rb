class SicCodeImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SIC_2007_DATA.csv')
  self.klass = SicCode

  def self.field_mapping
    {
      'UK SIC 2007'           => :code,
      'Activity Description'  => :description,
      'EFG Eligibility'       => :eligible
    }
  end

  def build_attributes
    row.each do |field_name, value|
      case field_name
      when 'EFG Eligibility'
        value = ['Eligible', 'Mixed Eligibility'].include?(value)
      else
        value
      end

      attributes[self.class.field_mapping[field_name]] = value
    end
  end

end
