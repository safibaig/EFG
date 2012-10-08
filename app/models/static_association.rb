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

  # find_all_by_*
  # find_by_*
  def self.method_missing(method, *args, &block)
    if match = method.to_s.match(/^find_all_by_(.*)/)
      return all.select { |item| item.send(match[1]) == args.first }.sort_by(&:id)
    end

    if match = method.to_s.match(/^find_by_(.*)/)
      return all.detect { |item| item.send(match[1]) == args.first }
    end

    super
  end
end
