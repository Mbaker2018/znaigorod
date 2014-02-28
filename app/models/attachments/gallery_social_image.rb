# encoding: utf-8

class GallerySocialImage < Attachment
  attr_accessible :file_url, :thumbnail_url

  # NOTE: emulate response for #<GallerySocialImage>.file.url
  def file
    Hashie::Mash.new :url => file_url
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
#

