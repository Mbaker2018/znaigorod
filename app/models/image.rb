class Image < ActiveRecord::Base
  attr_accessible :description, :url

  belongs_to :imageable, :polymorphic => true

  default_scope :order => :id

  after_create :index_imageable
  after_destroy :index_imageable

  private
  def index_imageable
    imageable.index_additional_attributes if imageable.respond_to? :index_additional_attributes
  end
end

# == Schema Information
#
# Table name: images
#
#  id             :integer         not null, primary key
#  url            :text
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  description    :text
#  imageable_type :string(255)
#  imageable_id   :integer
#

