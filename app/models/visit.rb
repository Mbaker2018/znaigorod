# encoding: utf-8

class Visit < ActiveRecord::Base
  paginates_per 10
  attr_accessible :user_id

  belongs_to :visitable, :polymorphic => true
  belongs_to :user

  has_many :messages, :as => :messageable, :dependent => :destroy
  has_one :feed, :as => :feedable, :dependent => :destroy

  validate :authenticated_user
  validates :user_id, :uniqueness => { :scope => [:visitable_id, :visitable_type] }

  scope :rendereable,       -> { where(:visitable_type => ['Afisha', 'Organization']) }

  def actual?
    if self.visitable.is_a?(Afisha)
      self.visitable.actual?
    else
      true
    end
  end

  private

  def authenticated_user
    errors.add :user_id, 'Вы не зарегистрированы' if user.nil?
  end
end

# == Schema Information
#
# Table name: visits
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  visitable_id   :integer
#  visitable_type :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

