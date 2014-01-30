# encoding: utf-8

class DiscountDecorator < ApplicationDecorator
  decorates :discount

  def goes_now?
    starts_at < Time.zone.now && ends_at > Time.zone.now
  end

  def will_goes?
    starts_at > Time.zone.now
  end

  def countdown_time
    if goes_now?
      ends_at.to_i * 1000
    else
      starts_at.to_i * 1000
    end
  end

  def tags_for_vk
    res = ""
    res << "<meta property='og:description' content='#{discount.description}'/>\n"
    res << "<meta property='og:site_name' content='#{I18n.t('meta.default.title')}' />\n"
    res << "<meta property='og:title' content='#{discount.title}' />\n"
    res << "<meta property='og:url' content='#{h.discount_url(discount)}' />\n"
    res << "<meta property='og:image' content='#{discount.poster_url}' />\n"
    res << "<meta name='image' content='#{discount.poster_url}' />\n"
    res << "<link rel='image_src' href='#{discount.poster_url}' />\n"
    res.html_safe
  end

  def when_with_price
    h.content_tag :p, h.content_tag(:span, human_when, :class => :when)
  end

  def human_when
    unless actual?
      return "Было: #{I18n.l(ends_at, :format => '%e.%m.%Y')}".squish
    else
      if constant?
        return 'Постоянная скидка'
      else
        if price.nil?
          return "Действует: #{I18n.l(starts_at, :format => '%e.%m')} - #{I18n.l(ends_at, :format => '%e.%m.%Y')}".squish
        elsif price.zero?
          return "Действует: #{I18n.l(starts_at, :format => '%e.%m')} - #{I18n.l(ends_at, :format => '%e.%m.%Y')}, бесплатно".squish
        elsif price < 0
          return "Действует: #{I18n.l(starts_at, :format => '%e.%m')} - #{I18n.l(ends_at, :format => '%e.%m.%Y')}, цена неизвестна".squish
        else
          return "Действует: #{I18n.l(starts_at, :format => '%e.%m')} - #{I18n.l(ends_at, :format => '%e.%m.%Y')}, #{h.number_to_currency(price, :unit => 'р.', :precision => 0)}".squish
        end
      end
    end
  end

  def human_place
    results = ''
    places.each do |place|
      if place.organization_id?
        results += PlaceDecorator.new(:organization => place.organization).place
      else
        results += PlaceDecorator.new(:latitude => place.latitude, :longitude => place.longitude, :title => place.address).place
      end
    end

    h.raw results
  end

  def place_without_map
    results = ''

    return results if places.empty?

    place = places.first

    if place.organization_id?
      results += h.link_to h.truncate(place.organization.try(:title), :length => 30), place.organization, :title => place.address
    else
      results += h.truncate(place.address, :length => 30)
    end

    h.raw results
  end

  def geo_present?
    places.any? && !places.first.latitude.blank? && !places.first.longitude.blank?
  end

  def similar_discount
    count = geo_present? ? 3 : 5
    HasSearcher.searcher(:similar_discount).more_like_this(discount).limit(count).results.map { |d| DiscountDecorator.new d }
  end

  def meta_keywords
    kind.map(&:text).map(&:mb_chars).map(&:downcase).join(', ')
  end

  def meta_description
    description.to_s.truncate(200, separator: ' ')
  end

  def smart_path(options = {})
    if discount.is_a?(OfferedDiscount) && discount.organizations.any?
      h.organization_path discount.organizations.first, options
    else
      h.discount_path discount, options
    end
  end

  def to_partial_path
    'discounts/discount_poster'
  end
end
