class QuestsCharacterId < ActiveRecord::Migration
  def change
    add_column(:quests, :character_id, :integer)
  end
end
