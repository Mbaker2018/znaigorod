class Coupon < ActiveRecord::Base
  extend Enumerize

  attr_accessible :description, :discount, :title, :organization_id, :price_with_discount,
                  :price_without_discount, :price, :organization_quota,
                  :kind, :image, :delete_image, :place, :vfs_path,
                  :count, :stale_at, :complete_at

  attr_accessor :delete_image

  has_attached_file :image, :storage => :elvfs, :elvfs_url => Settings['storage.url']

  delegate :clear, :to => :image, :allow_nil => true, :prefix => true

  before_save :set_discount
  before_update :image_destroy

  belongs_to :organization

  enumerize :kind, in: [:certificate, :coupon], predicates: true

  validates_presence_of :kind, :place, :stale_at, :complete_at

  def self.generate_vfs_path
    "/znaigorod/coupons/#{Time.now.strftime('%Y/%m/%d/%H-%M')}-#{SecureRandom.hex(4)}"
  end

  def get_organization_id
    self.try(:organization_id)
  end

  private

  def image_destroy
    if self.delete_image
      self.image.destroy
      self.image_url = nil
    end
  end

  def set_discount
    if self.price_without_discount? & self.price_with_discount?
      self.discount = (self.price_without_discount - self.price_with_discount) * 100 / price_without_discount 
    else
      self.discount = nil
    end
  end

end

# == Schema Information
#
# Table name: coupons
#
#  id                     :integer          not null, primary key
#  title                  :string(255)
#  description            :text
#  discount               :integer
#  vfs_path               :string(255)
#  organization_id        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  image_file_name        :string(255)
#  image_content_type     :string(255)
#  image_file_size        :integer
#  image_updated_at       :datetime
#  image_url              :text
#  price_with_discount    :integer
#  price_without_discount :integer
#  organization_quota     :integer
#  price                  :integer
#  kind                   :string(255)
#

