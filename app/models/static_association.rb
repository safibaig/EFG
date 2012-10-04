class StaticAssociation < OpenStruct
  class << self
    attr_accessor :data
  end

  def self.all
    @all ||= data.map { |d|
      new.tap { |item|
        d.each_pair { |k, v| item.send("#{k}=", v) }
      }
    }
  end

  def self.find(id)
    all.detect { |item|
      item.id == id
    }
  end

  def self.find_by_name(name)
    all.detect { |item|
      item.name == name
    }
  end
end
