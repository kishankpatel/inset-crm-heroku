# == Schema Information
#
# Table name: note_attachments
#
#  id                      :integer          not null, primary key
#  note_id                 :integer
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organization_id         :integer
#  is_archive              :boolean          default(FALSE)
#

class NoteAttachment < ActiveRecord::Base   
   attr_accessible :note_id, :attachment,:attachment_file_name,:attachment_content_type, :attachment_file_size, :attachment_updated_at, :organization_id, :is_archive

   belongs_to :note , :class_name=>"Note", :foreign_key => "note_id"
    Paperclip.interpolates :organization_id do |attachment, style|
      attachment.instance.organization_id
    end
   has_attached_file :attachment,
                  :storage => :s3,
                  :s3_credentials => S3_CREDENTIALS,
                  :path => "/:organization_id/notes/:id/:basename.:extension",
                  :url => "/:organization_id/notes/:id/:basename.:extension"
                  
  #validates_attachment_content_type :attachment, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif","application/pdf", "application/xlsx", "application/xls", "application/doc", "application/docx", "application/ppt", "application/pptx","audio/mp3","audio/mpeg","audio/mpeg3","audio/x-mpeg-3"]
  #validates_attachment_content_type :attachment, :content_type => ["image/*","application/*","audio/*","video/*"]
  before_create :update_organization_id

  def update_organization_id
    self.organization_id = self.note.organization_id
  end
end
