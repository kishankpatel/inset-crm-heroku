class AddOrganizationIdToNoteAttachment < ActiveRecord::Migration
  def change
    add_column :note_attachments, :organization_id, :integer
    NoteAttachment.all.each do |note_attachment|
    	note_attachment.update_column(:organization_id, note_attachment.note.organization_id)
    end
    puts "----- completed ----"
  end
end
