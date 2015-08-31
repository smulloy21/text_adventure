class InitialTables < ActiveRecord::Migration
  def change
    create_table(:characters) do |t|
      t.column(:name, :string)

      t.timestamps
    end
    create_table(:quests) do |t|
      t.column(:name, :string)

      t.timestamps
    end
    create_table(:scenes) do |t|
      t.column(:name, :string)
      t.column(:keyword, :string)
      t.column(:description, :string)
      t.column(:previous_scene, :int)
      t.column(:quest_id, :int)

      t.timestamps
    end
  end
end
