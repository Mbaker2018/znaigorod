class NewSaunyPresenter < NewOrganizationsPresenter
  def available_sortings
    sauna_halls_presenter.class.available_sortings
  end

  def sauna_halls_presenter
    @sauna_halls_presenter ||= SaunaHallsPresenter.new(params.merge(:page => clients_page, :per_page => clients_per_page))
  end
  delegate :price_filter_used?, :price,
    :capacity_filter_used?, :capacity_hash,
    :pool_features_filter_used?, :available_pool_features, :selected_pool_features,
    :baths_filter_used?, :available_baths, :selected_baths,
    :features_filter_used?, :available_features, :selected_features,
    :sauna_hall_ids,
    :to => :sauna_halls_presenter

  def clients_results
    @clients_results ||= begin
                           search = Organization.search {
                             paginate :page => clients_page, :per_page => clients_per_page
                             with :id, clients_organization_ids

                             if query
                               keywords query
                             else
                               order_by criterion, sauna_halls_presenter.direction unless criterion == 'price'
                             end
                           }

                           search.results
                         end
  end

  def tile_view_clients_per_page
    9
  end

  def clients_organization_ids
    sauna_ids = sauna_halls_presenter.search_with_groups.group(:sauna_id).groups.map(&:value).map(&:to_i)

    ids = Sauna.where(:id => sauna_ids).pluck(:organization_id)

    ids.any? ? ids : nil
  end

  def not_clients_results
    @not_clients_results ||= begin
                               search = Organization.search {
                                 paginate :page => not_clients_page, :per_page => not_clients_per_page
                                 with :id, not_clients_organization_ids if not_clients_organization_ids.any?

                                 if query
                                   keywords query
                                 else
                                   order_by criterion, sauna_halls_presenter.direction unless criterion == 'price'
                                 end
                               }

                               search.results
                             end
  end

  def not_clients_organization_ids
    @not_clients_organization_ids ||= begin
                                        ids = Sauna.search_ids {
                                          fulltext query

                                          any_of do
                                            with(:with_sauna_halls, false)
                                            without(:status, :client)
                                          end

                                          paginate(:page => 1, :per_page => 10_000)
                                        }

                                        Sauna.where(:id => ids).pluck(:organization_id)
                                      end
  end

  def show_not_clients_in_avdanced_filter?
    advanced_filter_used? ? false : true
  end
end
