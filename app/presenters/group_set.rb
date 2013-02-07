class GroupSet
  class Group
    attr_reader :name, :objects

    def initialize(name)
      @name = name
      @objects = []
    end

    def <<(object)
      @objects << object
    end
  end

  include Enumerable

  def self.group
    Group
  end

  def self.filter(objects)
    group_set = new
    group_set.filter(objects)
    group_set
  end

  def initialize
    @groups = {}
  end

  def groups
    @groups.keys
  end

  def add(name, &filter)
    group = self.class.group.new(name)
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
