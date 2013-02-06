class GroupSet
  class Group
    attr_reader :name, :loans

    def initialize(name)
      @name = name
      @loans = []
    end

    def <<(loan)
      @loans << loan
    end
  end

  include Enumerable

  def initialize
    @groups = {}
  end

  def add(name, &filter)
    group = Group.new(name)
    @groups[group] = filter
    group
  end

  def each(&block)
    @groups.keys.each(&block)
  end

  def filter(objects)
    objects.each do |object|
      @groups.each do |group, filter|
        if filter.call(object)
          group << object
          break
        end
      end
    end
  end
end
