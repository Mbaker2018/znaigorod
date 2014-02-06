# encoding: utf-8

class PostDecorator < ApplicationDecorator
  decorates :post

  include OpenGraphMeta

  delegate :title, :html_content, :kind, to: :post

  def truncated_title(length, separator = ' ')
    title.length > length ?
      title.text_gilensize.truncated(length, separator) :
      title.text_gilensize
  end

  def truncated_title_link(length, options = { separator: ' ', anchor: nil })
    if title.length > length
      h.link_to(truncated_title(length, options[:separator]), h.post_path(post, anchor: options[:anchor]), :title => title)
    else
      h.link_to(title.text_gilensize, h.post_path(post, anchor: options[:anchor]))
    end
  end

  def show_url
    @show_url ||= h.post_url(post)
  end

  def annotation_image(width, height)
    if post.poster_url?
      post.poster_url
    elsif post.poster_image_url?
      h.resized_image_url(post.poster_image_url, width, height)
    else
      'public/post_poster_stub.jpg'
    end
  end

  # overrides OpenGraphMeta.object_image
  def object_image
    annotation_image(242, 180)
  end

  def date
    date = post.created_at || Time.zone.now

    h.content_tag :div, I18n.l(date, :format => "%d %B %Y"), :class => :date
  end

  def html_content
    @html_content ||= content.to_s.as_html
  end

  def similar_posts
    HasSearcher.searcher(:similar_posts).more_like_this(model).limit(3).results
  end
end
