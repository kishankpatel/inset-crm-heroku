class AddIsArchiveToNoteAttachment < ActiveRecord::Migration
  def change
    add_column :note_attachments, :is_archive, :boolean, default: false
  end
end
