class CreateObservationsTable < ActiveRecord::Migration
  def change
    create_table(:observations) do |t|
      t.column(:name, :string)
      t.column(:description, :string)
      t.column(:scene_id, :integer)
      t.column(:keyword, :string)
      t.column(:required, :boolean)

      t.timestamps
    end
  end
end
