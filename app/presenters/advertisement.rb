# encoding: utf-8

class Advertisement
  include ActiveAttr::MassAssignment
  attr_accessor :list, :page, :places

  def initialize(args)
    super(args)
    @configuration = (YAML.load_file(Rails.root.join('config', 'advertisement.yml'))[@list.to_s] || {})['places'] || []
    @configuration = @configuration.to_a
    initialize_places
  end

  def initialize_places
    @places ||= [].tap do |array|
      @configuration.each do |place_config|
        place_in_list, place_config = place_config[0], place_config[1]
        from, to = Time.zone.parse(place_config['from']), Time.zone.parse(place_config['to'])
        next if from >= Time.zone.now || to <= Time.zone.now
        share_config = {
          :list => @list,
          :replaced_count => place_config['replaced_count'],
          :page => place_in_list.split('.').first.to_i,
          :position => place_in_list.split('.').second.to_i
        }
        array << case place_config['content_type']
        when 'afisha'
          afisha_adv = AfishaAdvertisementPlace.new(share_config.merge(slug: place_config['afisha_slug']))
          afisha_adv.afisha ? afisha_adv : nil
        when 'discount'
          discount_adv = DiscountAdvertisementPlace.new(share_config.merge(slug: place_config['discount_slug']))
          discount_adv.discount ? discount_adv : nil
        when 'webcam'
          WebcamAdvertisementPlace.new(share_config)
        when 'post'
          PostAdvertisementPlace.new(share_config)
        when 'banner'
          BannerAdvertisementPlace.new(share_config.merge({
            image: place_config['image'],
            link: place_config['link'],
            width: place_config['width'],
            height: place_config['height']
          }))
        else
          nil
        end
        array.compact!
      end
    end
  end

  def places_at(page)
    @places_at_page ||= places.select {|pl| pl.page == page }
  end

  def afishas
    @afishas ||= places.select {|pl| pl.is_a?(AfishaAdvertisementPlace) }.map(&:afisha)
  end

  class AdvertisementPlace
    include ActiveAttr::MassAssignment
    attr_accessor :page, :position, :replaced_count, :list
  end

  class AfishaAdvertisementPlace < AdvertisementPlace
    attr_accessor :slug, :afisha

    def initialize(args)
      super(args)
      @afisha = Afisha.published.find_by_slug(slug)
    end

    def partial
      "advertisements/#{list}_afisha_#{replaced_count}"
    end

    def decorated_afisha
      @decorated_afisha ||= AfishaDecorator.new(afisha)
    end

  end

  class DiscountAdvertisementPlace < AdvertisementPlace
    attr_accessor :slug, :discount

    def initialize(args)
      super(args)
      @discount = Discount.published.find_by_slug(slug)
    end

    def to_partial_path
      "advertisements/#{list}_discount_#{replaced_count}"
    end

    def decorated_discount
      @decorated_discount ||= DiscountDecorator.new(discount)
    end

  end

  class WebcamAdvertisementPlace < AdvertisementPlace
    attr_accessor :webcam

    def initialize(args)
      super(args)
      @webcam ||= Webcam.published.order('RANDOM()').limit(1).first
    end

    def partial
      "advertisements/#{list}_webcam_#{replaced_count}"
    end
  end

  class PostAdvertisementPlace < AdvertisementPlace
    def initialize(args)
      super(args)
    end

    def partial
      "advertisements/#{list}_widget_#{replaced_count}"
    end
  end

  class BannerAdvertisementPlace < AdvertisementPlace
    attr_accessor :link, :image, :width, :height, :title

    def initialize(args)
      super(args)
    end

    def partial
      "advertisements/#{list}_banner_#{width}_#{height}"
    end
  end
end
