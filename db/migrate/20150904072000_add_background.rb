class AddBackground < ActiveRecord::Migration
  def change
    add_column(:scenes, :background, :string)
  end
end
