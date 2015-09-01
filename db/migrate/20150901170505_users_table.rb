class UsersTable < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.column(:name, :string)
      t.column(:password, :varchar)

      t.timestamps
    end

    add_column(:characters, :user_id, :integer)
  end
end
