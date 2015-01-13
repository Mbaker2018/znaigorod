class My::RelatedItemsController < ApplicationController
  def afishas
    searcher = HasSearcher.searcher(:afishas, :q => search_param, :state => 'published')
      .paginate(:page => page, :per_page => per_page)

    @related_afishas = searcher.results
    @related_items = related_items("afisha")

    render :partial => 'my/related_items/afishas' if request.xhr?
  end

  def organizations
    searcher = HasSearcher.searcher(:organizations, :q => search_param, :state => 'published')
      .order_by_rating
      .paginate(page: page, per_page: per_page)

    @related_items = related_items("organization")
    @related_organizations = searcher.results

    render :partial => 'my/related_items/organizations' if request.xhr?
  end

  def reviews
    searcher = HasSearcher.searcher(:reviews, :q => search_param, :state => 'published')
      .without_questions
      .order_by_creation
      .paginate(page: page, per_page: per_page)

    @related_items=related_items("review")
    @related_reviews = searcher.results

    render :partial => 'my/related_items/reviews' if request.xhr?
  end

  def photogalleries
    searcher = HasSearcher.searcher(:photogalleries, :q => search_param)
      .order_by_title
      .paginate(page: page, per_page: per_page)

    @related_items=related_items("photogallery")
    @related_photogalleries = searcher.results

    render :partial => 'my/related_items/photogalleries' if request.xhr?
  end

  def discounts
    searcher = HasSearcher.searcher(:discounts, :q => search_param)
      .paginate(page: page, per_page: per_page)

    @related_items=related_items("discount")
    @related_discounts = searcher.results

    render :partial => 'my/related_items/discounts' if request.xhr?
  end

  private
  def related_items(item_name)
    return [] unless params[:related_items_ids]

    params[:related_items_ids].inject([]) { |array, item|
      type, id = item.split("_")

      array << id.to_i if item_name == type

      array
    }
  end

  def search_param
    params[:search_param]
  end

  def per_page
    12
  end

  def page
    params[:page]
  end
end
