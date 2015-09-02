class QuestsTableRatings < ActiveRecord::Migration
  def change
    add_column(:quests, :rating, :float)
    add_column(:quests, :times_rated, :integer)
    add_column(:quests, :times_completed, :integer)

    rename_column(:quests, :character_id, :user_id)
  end
end
