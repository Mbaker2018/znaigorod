# encoding: utf-8

class Attachment < ActiveRecord::Base
  attr_accessible :file, :description

  belongs_to :attachable, :polymorphic => true

  default_scope :order => 'position, id'

  def partial_for_render_object
    "#{self.class.name.underscore.pluralize}/#{self.class.name.underscore}"
  end

  def to_s
    description? ? description.truncate(30) : 'Без описания'
  end
end

# == Schema Information
#
# Table name: attachments
#
#  id                :integer          not null, primary key
#  attachable_id     :integer
#  attachable_type   :string(255)
#  description       :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  type              :string(255)
#  thumbnail_url     :text
#  height            :integer
#  width             :integer
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#  file_url          :text
#  file_image_url    :string(255)
#  position          :integer
#  user_id           :integer
#

