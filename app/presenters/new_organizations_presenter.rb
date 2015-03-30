class NewOrganizationsPresenter
  attr_accessor :params

  def initialize(params)
    @params = params
  end

  def old_presenter
    @old_presenter ||= OrganizationsCatalogPresenter.new(params)
  end

  # TODO: implement
  def page_header
    nil
  end

  def order_by_param
    params[:order_by] || 'activity'
  end

  def sortings_links
    %w[activity rating title].map do |value|
      {
        title: I18n.t("organization.sort.#{value}"),
        parameters: params.merge(order_by: value),
        selected: order_by_param == value
      }
    end
  end

  def category
    @category ||= OrganizationCategory.find_by_slug(params[:slug])
  end

  def promoted_clients
    orgs = Organization.search {
      with :status, :client
      paginate :page => 1, :per_page => 7
      order_by :positive_activity_date, :desc
    }.results

    OrganizationDecorator.decorate orgs
  end

  def view_type
    params[:view_type] || 'list'
  end

  def clients_per_page
    return 14 if view_type == 'tile'

    Organization.search {
      with :status, :client
      with :organization_category_slugs, category.slug if category
    }.results.total_count
  end

  def clients
    orgs = Organization.search {
      with :status, :client
      with :organization_category_slugs, category.slug if category
      paginate :page => params[:page] || 1, :per_page => clients_per_page

      case order_by_param
      when 'activity'
        order_by :positive_activity_date, :desc
      when 'title'
        order_by :title, :asc
      when 'rating'
        order_by :total_rating, :desc
      else
        order_by :positive_activity_date, :desc
      end
    }.results

    OrganizationDecorator.decorate orgs
  end


  def not_clients_per_page
    view_type == 'tile' ? 14 : 40
  end

  def not_clients
    orgs = Organization.search {
      without :status, :client
      with :organization_category_slugs, category.slug if category
      paginate :page => params[:page] || 1, :per_page => not_clients_per_page

      case order_by_param
      when 'activity'
        order_by :positive_activity_date, :desc
      when 'title'
        order_by :title, :asc
      when 'rating'
        order_by :total_rating, :desc
      else
        order_by :positive_activity_date, :desc
      end
    }.results

    OrganizationDecorator.decorate orgs
  end
end
