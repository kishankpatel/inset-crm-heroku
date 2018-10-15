namespace :inset do  
  task :update_organization_ids => :environment do
  	Organization.all.each do |org|
      if(!org.resource_setting.present?)
        rs =ResourceSetting.new
        rs.organization_id = org.id
        rs.hours_of_work=8
        rs.week_off_days=[0,6]
        rs.save
      end
    end
  end
  task :create_note_types_for_missing_orgs => :environment do
    note_types = ["Follow-Up","Suggestion","Reminder","Conversation","Files","Quote"]
    Organization.all.each do |org|
      if(!org.note_types.present?)
        note_types.each do |note_type|
          NoteType.create :organization_id => org.id, :name => note_type
        end
      end
    end
  end
  task :insert_user_labels_for_missing_orgs => :environment do 
    Organization.all.each do |org|
      if(!org.user_labels.present?)
        org.user_labels.create(name: "Inbound")
        org.user_labels.create(name: "Outbound")
        org.user_labels.create(name: "Uncategorised")
      end
    end
  end
  task :update_organization_ids_resource => :environment do
    JobTimeLog.all.each do |jtl|
      if(!jtl.organization_id.present?)
        jtl.organization_id = jtl.project_job.organization_id
        jtl.save
      end
    end
    ResourceDistribution.all.each do |rd|
      if(!rd.organization_id.present?)
        rd.organization_id = rd.project_job.organization_id
        rd.save
      end
    end
  end
  task :update_original_id_of_project_stage => :environment do
    Organization.all.each do |org|
      project_stages = org.project_stages.where("name in ('New','Completed')").all
      if project_stages.count > 0
        project_stages.each do |ps|
          if ps.name == 'New'
            ps.original_id = 1
            ps.save
          end
          if ps.name == 'Completed'
            ps.original_id = 2
            ps.save
          end
        end
      end
      project_stage = org.project_stages.where("name in ('New')").first
      if(!project_stage.present? )
        ProjectStage.create(:organization_id=>org.id,  :is_active=>true, :name => 'New', :position=>1,:original_id=>1)
      end
      project_stage = org.project_stages.where("name in ('Completed')").first
      if(!project_stage.present? )
        ProjectStage.create(:organization_id=>org.id,  :is_active=>true, :name => 'Completed', :position=>2,:original_id=>2)
      end
    end
  end
  task :update_original_id_of_project_and_task_types => :environment do
    ProjectJobType.all.each do |pjt|
      if(pjt.name.downcase == 'appointment')
        pjt.original_id = 1
        pjt.save
      end
    end
    Organization.all.each do |org|
      project_job_type = org.project_job_types.where("name in ('Appointment')").first
      if(!project_job_type.present? )
        ProjectJobType.create(:organization_id=>org.id,  :name => 'Appointment', :original_id=>1)
      end
      task_type = org.task_types.where("name in ('Appointment')").first
      if(!task_type.present? )
        TaskType.create(:organization_id=>org.id, :name => 'Appointment', :original_id=>1)
      end

    end
  end
  task :fill_link_with_for_projects => :environment do
    Project.all.each do |prj|
      if(!prj.linked_with.present?)
        if(prj.deal.present?)
          prj.linked_with = "Opportunity"
          prj.individual_contact_id = prj.deal.individual_contact_id
          prj.save
        end
        if(prj.individual_contact_id.present? && !prj.deal.present?)
          prj.linked_with = "Contact"
          prj.save
        end
      end
    end
  end 
  task :insert_default_data_company_industries => :environment do
    CompanyIndustry.create(industry_code: 11, name: 'Agriculture, Forestry, Fishing and Hunting')
    CompanyIndustry.create(industry_code: 21, name: 'Mining, Quarrying, and Oil and Gas Extraction')
    CompanyIndustry.create(industry_code: 22, name: 'Utilities')
    CompanyIndustry.create(industry_code: 23, name: 'Construction')
    CompanyIndustry.create(industry_code: 31, name: 'Manufacturing')
    CompanyIndustry.create(industry_code: 42, name: 'Wholesale Trade')
    CompanyIndustry.create(industry_code: 44, name: 'Retail Trade')
    CompanyIndustry.create(industry_code: 48, name: 'Transportation and Warehousing')
    CompanyIndustry.create(industry_code: 51, name: 'Information')
    CompanyIndustry.create(industry_code: 52, name: 'Finance and Insurance')
    CompanyIndustry.create(industry_code: 53, name: 'Real Estate and Rental and Leasing')
    CompanyIndustry.create(industry_code: 54, name: 'Professional, Scientific, and Technical Services')
    CompanyIndustry.create(industry_code: 55, name: 'Management of Companies and Enterprises')
    CompanyIndustry.create(industry_code: 56, name: 'Administrative and Support and Waste Management and Remediation Services')
    CompanyIndustry.create(industry_code: 61, name: 'Educational Services')
    CompanyIndustry.create(industry_code: 62, name: 'Health Care and Social Assistance')
    CompanyIndustry.create(industry_code: 71, name: 'Arts, Entertainment, and Recreation')
    CompanyIndustry.create(industry_code: 72, name: 'Accommodation and Food Services')
    CompanyIndustry.create(industry_code: 81, name: 'Other Services (except Public Administration)')
  end

  task :create_administrative_project => :environment do
    Organization.all.each do |org|
      p org.name
      if( !(org.projects.where(:project_type=>'Administrative').first).present?)
        p "project not found for this org : " + org.name
        super_admin = org.get_super_admin
        if(super_admin.present?)
          prj = Project.create!(:organization_id=>org.id,  :is_accessible=>true, :name=>"Administrative",:short_name=>"Admin",:description=>'All Administrative Tasks',:project_type=>'Administrative',:project_manager_id => super_admin.id,:created_by=>super_admin.id,:status =>"Started")
          p prj.name
        end
      end
    end
  end
  task :update_activities_source_type => :environment do
    Activity.where("activity_type in (?)", [ "Profile","User"]).update_all(:source_type => 'User')
    Activity.where("activity_type in (?)", [ "DealsContact",  "Deal", "Task", "DealTransaction", "MailLetter", "Note", "DealClosed"]).update_all(:source_type => 'Deal')
    Activity.where("activity_type in (?)", [ "IndividualContact"]).update_all(:source_type => 'IndividualContact')
    Activity.where("activity_type in (?)", [ "Organization"]).update_all(:source_type => 'CompanyContact')
    Activity.where("activity_type in (?)", [ "Project" "ProjectJob"]).update_all(:source_type => 'Project')
    #"IndividualContact", "Project" "ProjectJob","Organization"
  end
end