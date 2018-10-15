# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  title            :string(50)       default("")
#  comment          :text
#  commentable_id   :integer
#  commentable_type :string(255)
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  status           :string(255)
#  assigned_to      :integer
#  priority         :string(255)
#  notify_email_ids :string(255)
#

class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment
  has_many :note, :class_name=>"Note", :as => :notable, :dependent => :destroy
  belongs_to :commentable, :polymorphic => true

  default_scope :order => 'created_at ASC'

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # NOTE: Comments belong to a user
  belongs_to :user
  attr_accessible :user_id, :comment, :assigned_to, :status, :notify_email_ids, :priority, :image
end
