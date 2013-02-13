class AddPhases < ActiveRecord::Migration

  # Avoid dependency on a model object which might not exist when this
  # migration is run.
  class User < ActiveRecord::Base
  end

  class SystemUser < User
  end

  class Phase < ActiveRecord::Base
    belongs_to :created_by, class_name: 'User'
    belongs_to :modified_by, class_name: 'User'
  end

  def up
    create_table :phases, :force => true do |t|
      t.string :name
      t.references :created_by
      t.references :modified_by
      t.timestamps
    end

    if !SystemUser.first
      # This requires a SystemUser, so ensure that one exists.
      system_user = SystemUser.new
      system_user.username = "system"
      system_user.save
    end

    (1..4).each do |i|
      phase = Phase.new
      phase.name = "Phase #{i}"
      phase.created_by = SystemUser.first
      phase.modified_by = SystemUser.first
      phase.save!
    end
  end

  def down
    drop_table :phases
  end
end