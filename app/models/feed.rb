class Feed < ActiveRecord::Base
  attr_accessible :feedable, :account, :created_at, :updated_at
  belongs_to :feedable, :polymorphic => true
  belongs_to :account

  def self.feeds_for_presenter(searcher_params)
    self.where(searcher_params).includes(:feedable).order('created_at DESC')
  end

  def self.feeds_for_state_machine(elem)
    puts 'asd'
    if %[Discount Coupon Certificate].include?(elem.class.name)
      self.create(
        :feedable => elem,
        :account => elem.account,
        :created_at => elem.created_at,
        :updated_at => elem.updated_at
      )
    elsif %[Afisha].include?(elem.class.name)
      self.create(
        :feedable => elem,
        :account => elem.user.account,
        :created_at => elem.created_at,
        :updated_at => elem.updated_at
      )
    end

  end

end

# == Schema Information
#
# Table name: feeds
#
#  id            :integer          not null, primary key
#  feedable_id   :integer
#  feedable_type :string(255)
#  account_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

