# encoding: utf-8

module Affiches
  module Entities
    class Afisha < Grape::Entity
      expose (:title)       { |model, options| AfishaDecorator.new(model).title.gsub(/\u00AD+/,'') }
      expose (:date)        { |model, options| AfishaDecorator.new(model).human_when.gsub(/\u00AD+/,'') }
      expose (:price)       { |model, options| AfishaDecorator.new(model).human_price.gsub(/\u00AD+/,'') }
      expose (:place)       { |model, options| AfishaDecorator.new(model).place.gsub(/\u00AD+/,'') }
      expose (:kind)        { |model, options| AfishaDecorator.new(model).kind.map(&:text).join(', ').gsub(/\u00AD+/,'') }
      expose (:url)         { |model, options| "#{Settings['app.url']}/afisha/#{model.slug}" }
      expose (:poster_url)  { |model, options| AfishaDecorator.new(model).resized_image_url(model.poster_url, 290, 390) }
    end

    class AfishaWithTicket < Afisha
      expose(:price) do |model, options|
        model.max_tickets_discount ?
          "#{model.max_tickets_discount.to_s} %" :
          AfishaDecorator.new(model).human_price.gsub(/\u00AD+/,'')
      end

      expose(:place) { |model, options| AfishaDecorator.new(model).afisha_place(:length => 256, :separator => ' ', :only_path => false) }
    end
  end

  class API < Grape::API
    prefix 'api'
    format :json

    resource :popular do
      get do
        present HasSearcher.searcher(:showings).order_by_rating.actual.results.map(&:afisha).uniq.first(6), :with => Entities::Afisha
      end
    end

    resources :afishas do
      get do
        Afisha.search { keywords params[:term]; order_by :created_at, :desc }.results.map do |afisha|
          { :value => afisha.id, :label => "#{afisha.title}, #{afisha.place}" }
        end
      end
    end

    resources :with_tickets do
      get do
        present Afisha.where(:id => AfishaPresenter.new(:has_tickets => true).collection.map(&:value)), :with => Entities::AfishaWithTicket
      end
    end
  end
end
