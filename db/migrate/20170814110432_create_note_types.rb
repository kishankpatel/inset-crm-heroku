class CreateNoteTypes < ActiveRecord::Migration
  def change
    create_table :note_types do |t|
      t.string :name
      t.references :organization

      t.timestamps
    end
    add_index :note_types, :organization_id
  end
end
