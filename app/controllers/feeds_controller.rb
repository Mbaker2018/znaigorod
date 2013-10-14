class FeedsController < ApplicationController

  inherit_resources

  actions :index

  layout false

  def index
    index! {
      unless params[:kind].nil?
        @feeds = end_of_association_chain.where(:feedable_type => params[:kind]).page(params[:page]).per(10)
      else
        @feeds = end_of_association_chain.page(params[:page]).per(10)
      end
    render @feeds and return
    }
  end

end
