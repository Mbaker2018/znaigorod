# encoding: utf-8

module CropedPoster
  extend ActiveSupport::Concern

  module ClassMethods
    def has_croped_poster(min_width: 300, min_height: 300, default_url: nil)
      @min_width, @min_height = min_width, min_height

      attr_accessible :crop_x, :crop_y, :crop_width, :crop_height, :min_width, :min_height,
        :set_region,
        :poster_image

      attr_accessor :crop_x, :crop_y, :crop_width, :crop_height, :min_width, :min_height,
        :set_region

      options = { :storage => :elvfs, :elvfs_url => Settings['storage.url'] }
      options.merge! :default_url => default_url if default_url.present?

      has_attached_file :poster_image, options

      # TODO
      validates_attachment :poster_image, :content_type => {
        :content_type => ['image/jpeg', 'image/jpg', 'image/png'],
        :message => 'Изображение должно быть в формате jpeg, jpg или png' }, :if => :poster_image?

      validates :poster_image, :dimensions => { :width_min => min_width, :height_min => min_height }, :if => :poster_image?

      after_validation :set_poster_url, :if => :set_region?
    end

    def min_width
      @min_width
    end

    def min_height
      @min_height
    end
  end

  def poster_image_original_dimensions
    @poster_image_original_dimensions ||= {}.tap { |dimensions|
      dimensions[:width] = StorageImageDimensions.new(poster_image_url).width
      dimensions[:height] = StorageImageDimensions.new(poster_image_url).height
    }
  end

  def set_region?
    set_region.present?
  end

  def side_max_size
    580.to_f
  end

  def resize_factor
    @resize_factor = poster_image_original_dimensions.values.max / side_max_size

    (@resize_factor < 1) ? 1.0 : @resize_factor
  end

  def poster_image_resized_dimensions
    return poster_image_original_dimensions if poster_image_original_dimensions.values.max < side_max_size

    {}.tap { |dimensions|
      dimensions[:width] = (poster_image_original_dimensions[:width] / resize_factor).round
      dimensions[:height] = (poster_image_original_dimensions[:height] / resize_factor).round
    }
  end

  private

  def set_poster_url
    if poster_image_url?
      rpl = 'region/' << [crop_width, crop_height, crop_x, crop_y].map(&:to_f).map { |v| v * resize_factor }.map(&:round).join('/')
      self.poster_url = poster_image_url.gsub(/\/\d+-\d+\//, "/#{rpl}/")
    end
  end
end
