class DiscountsController < ApplicationController
  inherit_resources

  actions :show

  def index
    @presenter = DiscountsPresenter.new(params.merge(:with_advertisement => true))
    @discounts = @presenter.decorated_collection

    render partial: 'discounts/discount_posters', layout: false and return if request.xhr?

    respond_to do |format|
      format.html

      format.rss { render :layout => false }
    end
  end

  def show
    show! {
      @discount = DiscountDecorator.new(@discount)
      @presenter = DiscountsPresenter.new(params.merge(:kind => @discount.kind.map(&:value).first, :type => @discount.model.type_for_solr))
      @discount.delay(:queue => 'critical').create_page_visit(request.session_options[:id], request.user_agent, current_user)
      @members = @discount.members.page(1).per(3)
    }
  end
end
