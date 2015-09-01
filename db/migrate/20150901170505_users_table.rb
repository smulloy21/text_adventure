class UsersTable < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.column(:name, :string)
      t.column(:password, :varchar)
      t.column(:character_id, :integer)

      t.timestamps
    end
  end
end
