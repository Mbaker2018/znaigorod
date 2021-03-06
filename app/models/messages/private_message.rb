# encoding: utf-8

class PrivateMessage < Message
  attr_accessible :account, :body, :state, :producer, :account_id

  scope :from, ->(account) { where(producer_id: account) }
  scope :to, ->(account) { where(account_id: account) }
  scope :dialog, ->(from, to) { where("(account_id = #{from} and producer_id = #{to}) or (account_id = #{to} and producer_id = #{from})") }
  scope :dialog_desc, ->(from, to) { where("(account_id = #{from} and producer_id = #{to}) or (account_id = #{to} and producer_id = #{from})").order("id DESC")  }

  validates_presence_of :body

  auto_html_for :body do
    html_escape
    simple_format
    znaigorod_link :target => "_blank", :rel => 'nofollow'
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
#  type             :string(255)
#  producer_type    :string(255)
#  invite_kind      :string(255)
#  agreement        :string(255)
#

