# == Schema Information
#
# Table name: note_types
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class NoteType < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name, :organization_id
  def self.get_color_code str
    if(str == "follow-up")
      color = "#075211"
    elsif(str == "suggestion")
      color = "#F4511E"
    elsif(str == "reminder")
      color = "#801818"
    elsif(str == "conversation")
      color = "#9575CD"
    elsif(str == "files")
      color = "#FFA726"
    elsif(str == "quote")
      color = "#4FC3F7"
    else
      color = "#888888"
    end
    return color
  end
end
