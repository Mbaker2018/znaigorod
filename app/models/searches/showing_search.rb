class ShowingSearch < Search
  attr_accessible :affiche_categories,
                  :ends_at_hour_gt,
                  :ends_at_hour_lt,
                  :per_page,
                  :price_gt,
                  :price_lt,
                  :starts_at_gt,
                  :starts_at_hour_gt,
                  :starts_at_hour_lt,
                  :starts_at_lt,
                  :starts_on_gt,
                  :starts_on_lt,
                  :tags

  attr_accessor :ends_at_hour_gt,
                :ends_at_hour_lt,
                :price_gt,
                :price_lt,
                :starts_at_hour_gt,
                :starts_at_hour_lt,
                :tags

  column :affiche_categories, :string
  column :ends_at_hour_gt,    :integer
  column :ends_at_hour_lt,    :integer
  column :per_page,           :integer
  column :price_gt,           :integer
  column :price_lt,           :integer
  column :starts_at_gt,       :datetime
  column :starts_at_hour_gt,  :integer
  column :starts_at_hour_lt,  :integer
  column :starts_at_lt,       :datetime
  column :starts_on_gt,       :date
  column :starts_on_lt,       :date
  column :tags,               :string

  default_value_for(:ends_at_hour_gt)   { DateTime.now.hour }
  default_value_for :price_gt,          0
  default_value_for :starts_at_hour_gt, 0
  default_value_for :starts_at_hour_lt, 24
  default_value_for(:starts_on_gt)      { Date.today }
  default_value_for :per_page,          1000

  def price_lt
    @price_lt.to_i.zero? ? 99999 : @price_lt
  end

  protected
    def search_columns
      @showing_search_columns ||= super.reject { |c| c.match(/(hour|price|tags)/) }
    end

    def additional_search(search)
      search.all_of do
        [*tags].each do |tag|
          with(:tags, tag)
        end
      end

      search.any_of do
        all_of do
          with(:starts_at_hour).greater_than(starts_at_hour_gt)
          with(:starts_at_hour).less_than(starts_at_hour_lt)
        end

        all_of do
          with(:ends_at_hour).greater_than(ends_at_hour_gt)
          with(:starts_at_hour).less_than(starts_at_hour_lt)
        end
      end

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

      search.adjust_solr_params {|params| params[:sort] = 'id desc'}
    end
end

# == Schema Information
#
# Table name: searches
#
#  affiche_categories :string
#  ends_at_hour_gt    :integer
#  ends_at_hour_lt    :integer
#  per_page           :integer
#  price_gt           :integer
#  price_lt           :integer
#  starts_at_gt       :datetime
#  starts_at_hour_gt  :integer
#  starts_at_hour_lt  :integer
#  starts_at_lt       :datetime
#  starts_on_gt       :date
#  starts_on_lt       :date
#  tags               :string
#

