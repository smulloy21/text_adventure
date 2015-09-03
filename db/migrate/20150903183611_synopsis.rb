class Synopsis < ActiveRecord::Migration
  def change
    add_column(:quests, :synopsis, :string)
  end
end
