class FeedsPresenter

  attr_accessor :kind_filter, :activity_filter, :account_id

  def initialize(params)
    @controller_name = params['controller']
    @activity_filter = FeedsActivityFilter.new(params['activity'])
    @kind_filter = FeedsKindFilter.new(params['kind'])
    @page = params['page']
    @page ||= 1
    @per_page = 10
    @account_id = params['id'] if params['id'].present?
    @account_id = params['account_id'] if params['account_id'].present?
    @searcher_params = {}
    searcher_params()
  end

  def private_feed?
    %w[my/accounts my/feeds].include?(@controller_name)
  end

  def public_feed?
    %w[accounts feeds].include?(@controller_name)
  end

  def kinds_links
    @kinds_links ||= [].tap { |array|
      @kind_filter.available_kind_values.each do |kind|
        array << {
          title: I18n.t("feed_kinds.#{kind}"),
          klass: kind,
          parameters: {
            kind: kind,
            activity: @activity_filter.kind,
          },
          selected: kind == @kind_filter.kind,
        }
      end
    }
  end

  def collection

    if public_feed?
      @feed ||= Kaminari.paginate_array(Feed.feeds_for_presenter(@searcher_params)).page(@page).per(@per_page)
    end

    if private_feed?
      if @activity_filter.of_friends?
        @feed ||= Kaminari.paginate_array(Account.find(@account_id).friends_feeds(@searcher_params)).page(@page).per(@per_page)

      elsif @activity_filter.of_me?
        @feed ||= Kaminari.paginate_array(Feed.feeds_for_presenter(@searcher_params)).page(@page).per(@per_page)

      else
        friends_params = {}
        if @searcher_params[:feedable_type].present?
          friends_params[:feedable_type] = @searcher_params[:feedable_type]
        end

        friends_feeds = Account.find(@account_id).friends_feeds(friends_params)
        my_feeds = Feed.feeds_for_presenter(@searcher_params)

        @feed = friends_feeds.concat my_feeds
        @feed.compact!

        unless @feed.blank?
          @feed = @feed.sort_by(&:created_at).reverse
        end

        @feed = Kaminari.paginate_array(@feed).page(@page).per(@per_page)
      end
    end

    @feed

  end

  def searcher_params

    @searcher_params[:feedable_type] = @kind_filter.kind.capitalize if @kind_filter.used?
    @searcher_params[:account_id] = @account_id if @account_id.present? && !@activity_filter.of_friends?
  end

end

class FeedsKindFilter

  attr_accessor :kind

  def initialize(kind)
    @kind = kind
  end

  def self.available_kind_values
    %w[all comment vote visit afisha invitation friend discount]
  end

  def available_kind_values
    self.class.available_kind_values
  end

  def kind
    available_kind_values.include?(@kind) ? @kind : 'all'
  end

  def used?
    kind != 'all'
  end

end

class FeedsActivityFilter

  attr_accessor :kind

  def initialize(kind)
    @kind = kind
  end

  def self.available_kind_values
    %w[all my friends]
  end

  def available_kind_values
    self.class.available_kind_values
  end

  def kind
    available_kind_values.include?(@kind) ? @kind : 'all'
  end

  def of_friends?
    @kind == 'friends'
  end

  def of_me?
    @kind == 'my'
  end

  def used?
    kind != 'all'
  end

end

class FeedsActivityFilter

  attr_accessor :kind

  def initialize(kind)
    @kind = kind
  end

  def self.available_kind_values
    %w[my friends]
  end

  def available_kind_values
    self.class.available_kind_values
  end

  def kind
    available_kind_values.include?(@kind) ? @kind : 'my'
  end

  def of_friends?
    @kind == 'friends'
  end

  def used?
    kind != 'my'
  end

end
