namespace :wus do
  task :insert_note_types => :environment do 
    Organization.all.each do |org|
	    note_types = ["Follow-Up","Suggestion","Reminder","Conversation","Files","Quote"]
		unless org.note_types.present?
		  note_types.each do |note_type|
	        NoteType.create :organization_id => org.id, :name => note_type
	      end
		end
        p "Note types insrted successfully on org: #{org.id}"
    end
  end
end