HasSearcher.create_searcher :total do
  models :affiche, :eating, :funny
  keywords :q

  scope do
    any_of do
      with(:last_showing_time).greater_than(DateTime.now)
      with(:kind, :organization)
    end
  end
end

HasSearcher.create_searcher :showing do
  models :showing

  property :affiche_id
  property :affiche_category
  property :starts_on, :modificators => [:greater_than, :less_than]
  property :starts_at_hour, :modificators => [:greater_than, :less_than]
  property :tags

  property :price, :modificators => [:greater_than, :less_than] do |search|
    price_gt = [0, search_object.price_greater_than.to_i].max
    price_lt = search_object.price_less_than.to_i.zero? ? 10_000_000 : search_object.price_less_than.to_i

    search.with(:price_min).greater_than(price_gt)
    search.with(:price_min).less_than(price_lt)

    search.any_of do
      all_of do
        with(:price_min).greater_than(price_gt)
        with(:price_max).less_than(price_lt)
      end

      all_of do
        with(:price_min).less_than(price_gt)
        with(:price_max).greater_than(price_gt)
      end

      all_of do
        with(:price_min).less_than(price_lt)
        with(:price_max).greater_than(price_lt)
      end
    end
  end

  scope :actual do
    with(:starts_at).greater_than DateTime.now
  end

  scope :today do
    with(:starts_at).less_than DateTime.now.end_of_day
  end

  scope :faceted do
    facet(:tags)
  end
end
