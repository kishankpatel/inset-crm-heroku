# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  organization_id    :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  imagable_type      :string(255)
#  imagable_id        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Image < ActiveRecord::Base
  belongs_to :imagable , :polymorphic=> true
  belongs_to :organization
  belongs_to :contact
  belongs_to :IndividualContact
  belongs_to :CompanyContact
  
  attr_accessible :imagable_id, :imagable_type, :image_content_type, :image_file_name, 
               :image_file_size, :image_updated_at, :organization, :imagable, :image,:organization_id
  
  Paperclip.interpolates :organization_id do |attachment, style|
    attachment.instance.organization_id
  end
  has_attached_file :image, :styles => { :icon => "50x50>", :thumb => "75x75>", :small => "150x150>", :medium => "200x200>" }, default_url: "/images/:style/missing.png"

end
