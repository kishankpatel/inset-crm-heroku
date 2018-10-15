namespace :wus do  
  
  task :move_s3_new_path => :environment do
   	FakeNoteAttachment.all.each do |fake_attachment|
   	puts "=============== Fake attachment:#{fake_attachment.id}"
	   deal_attachment = NoteAttachment.find(fake_attachment.id)
	   deal_attachment.update_attribute(:attachment, fake_attachment.attachment)
	   #fake_attachment.image.destroy
	end
  end
end