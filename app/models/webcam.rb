# encoding: utf-8

class Webcam < ActiveRecord::Base

  attr_accessible :kind, :title, :slug, :url, :parameters, :cab, :width, :height,
                  :address, :latitude, :longitude, :state, :snapshot_url, :snapshot_image,
                  :our_cam

  validates_presence_of :kind, :title, :url, :width, :height,
                        :address, :latitude, :longitude

  scope :ordered, -> { order('title') }

  scope :published, -> { where(:state => true) }
  scope :our,       -> { where(:our_cam => true) }

  extend FriendlyId
  friendly_id :title, use: :slugged

  extend Enumerize
  enumerize :kind, in: [:webcam_jw, :webcam_uppod, :webcam_axis, :webcam_swf]

  default_value_for :state, true

  has_attached_file :snapshot_image, :storage => :elvfs, :elvfs_url => Settings['storage.url']

  validates_attachment :snapshot_image, :content_type => {
    :content_type => ['image/jpeg', 'image/jpg', 'image/png'],
    :message => 'Изображение должно быть в формате jpeg, jpg или png'
  }

  def self.snapshot_href_for_index
    "#{Settings['storage.url']}/files/55961/640-480/webcams_with_logo.jpg"
  end

  def snapshot_href
    return snapshot_url if snapshot_url?
    return snapshot_image_url if snapshot_image_url?
    self.class.snapshot_href_for_index
  end

end

# == Schema Information
#
# Table name: webcams
#
#  id                          :integer          not null, primary key
#  kind                        :string(255)
#  title                       :text
#  slug                        :text
#  url                         :text
#  parameters                  :text
#  cab                         :text
#  width                       :integer
#  height                      :integer
#  address                     :text
#  latitude                    :string(255)
#  longitude                   :string(255)
#  state                       :boolean
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  snapshot_url                :text
#  snapshot_image_file_name    :string(255)
#  snapshot_image_content_type :string(255)
#  snapshot_image_file_size    :integer
#  snapshot_image_updated_at   :datetime
#  snapshot_image_url          :text
#  our_cam                     :boolean          default(FALSE)
#

