# encoding: utf-8

class Message < ActiveRecord::Base
  attr_accessible :account, :body, :state, :kind, :producer, :messageable

  belongs_to :account
  belongs_to :producer, class_name: 'Account'
  belongs_to :messageable, :polymorphic => true

  extend Enumerize
  enumerize :state, in: [:new, :read], default: :new, predicates: true, scope: true
  enumerize :kind, in: [:new_comment, :reply_on_comment, :afisha_published, :afisha_returned, :user_vote_afisha, :user_vote_comment, :user_visit_afisha, :user_add_friend]

  def change_message_status
    self.new? ? self.state = :read : self.state = :new
    self.save
  end

end

# == Schema Information
#
# Table name: messages
#
#  id               :integer          not null, primary key
#  messageable_id   :integer
#  messageable_type :string(255)
#  account_id       :integer
#  producer_id      :integer
#  body             :text
#  state            :string(255)
#  kind             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

