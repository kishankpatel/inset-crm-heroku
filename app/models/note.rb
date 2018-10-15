# == Schema Information
#
# Table name: notes
#
#  id                      :integer          not null, primary key
#  organization_id         :integer
#  notes                   :text
#  file_description        :string(255)
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  notable_type            :string(255)
#  notable_id              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  created_by              :integer
#  is_public               :boolean          default(FALSE)
#  title                   :string(255)
#  note_type_id            :integer
#

class Note < ActiveRecord::Base
  belongs_to :notable , :polymorphic=> true
  belongs_to :organization
  belongs_to :user, :class_name=>"User",:foreign_key=>"created_by"
  has_many :note_attachments, :class_name => "NoteAttachment", :foreign_key => "note_id", :dependent => :destroy
  belongs_to :note_type

  attr_accessible :attachment_content_type, :attachment_file_name, :attachment_file_size, :attachment_updated_at, 
      :file_description, :notable_id, :notable_type, :notes,:organization,:notable,:attachment, :created_by,:created_at, :is_public, :title, :note_type_id
      
       
  # has_attached_file :attachment,
                  # :storage => :s3,
                  # :s3_credentials => S3_CREDENTIALS,
                  # :path => "notes/:id/:basename.:extension",
                  # :url => "notes/:id/:basename.:extension"
  #include Tire::Model::Search
  #include Tire::Model::Callbacks
  #mapping do
   # indexes :title,analyzer: 'snowball', boost: 100
   # indexes :image_url
   # indexes :initiator_name,analyzer: 'snowball', boost: 100
   # indexes :assigned_user_name,analyzer: 'snowball', boost: 100
   # indexes :notable_type_data,analyzer: 'snowball', boost: 100
   # indexes :notable_type_title,analyzer: 'snowball', boost: 100
  #end
  
  def to_indexed_json
    to_json( 
      #:only   => [ :id, :name, :normalized_name, :url ],
      :methods   => [:image_url, :initiator_name, :assigned_user_name,:title, :notable_type_data, :notable_type_title]
    )
  end
  def created_user
    self.organization.users.where("id=?",self.created_by).first
  end

  def image_url
    #if user.present? && user.image.present? && user.image.image.present?
    #  user.image.image.url(:icon)
    #else
    #  "/assets/no_user.png"
    #end
    "#{ENV['cloudfront']}/assets/note.png"
  end
  
  
  def initiator_name
    user.present? ? user.full_name : ""
  end
  
  def assigned_user_name
    user.present? ? user.full_name : ""
  end  
  
  # def title
  #   notes
  # end
  
  def notable_type_data
    notable_type
  end
  
  def notable_type_title
    if notable.present?
      notable.title
    else
      ""
    end
  end
  def attachment_urls
    note_attachments.map{|att| att.attachment.url}
  end
  
  def attachment_name
    note_attachments.map{|att| att.attachment_file_name} 
  end
  
  

end
