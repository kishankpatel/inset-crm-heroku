# == Schema Information
#
# Table name: widgets
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  organization_id  :integer
#  chart            :boolean          default(TRUE)
#  activities       :boolean          default(TRUE)
#  feeds            :boolean          default(TRUE)
#  tasks            :boolean          default(TRUE)
#  usage            :boolean          default(TRUE)
#  summary          :boolean          default(TRUE)
#  pie_chart        :boolean          default(TRUE)
#  column_chart     :boolean          default(TRUE)
#  line_chart       :boolean          default(TRUE)
#  statistics_chart :boolean          default(TRUE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Widget < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  attr_accessible :activities, :chart, :feeds, :line_chart, :pie_chart, :tasks,:usage,:summary,:statistics_chart,:column_chart, :organization_id, :user
  
  
   
  def self.get_widget diagram,  orgid, usrid
    t = self .find_by_user_id_and_organization_id usrid,orgid
    ##FIXME AMT  
    if t.nil?
     return false
    else
     if diagram == "charts"
       tt = t.chart
     elsif diagram == "activities"
       tt = t.activities
     elsif diagram == "feeds"
       tt = t.feeds
     elsif diagram == "tasks"
       tt = t.tasks
     elsif diagram == "usage"
       tt = t.usage 
     elsif diagram == "summary"
       tt = t.summary
     #admin charts
     elsif diagram == "pie_chart"
       tt = t.pie_chart
     elsif diagram == "column_chart"
       tt = t.column_chart 
     #non admin charts
     elsif diagram == "statistics_chart"
       tt = t.statistics_chart
     elsif diagram == "line_chart"
       tt = t.line_chart 
     end
    end
  end
  
end
