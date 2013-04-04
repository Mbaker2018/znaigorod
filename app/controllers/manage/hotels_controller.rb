class Manage::HotelsController < Manage::ApplicationController
  defaults :singleton => true

  actions :all, :except => :show

  belongs_to :organization, :optional => true

  def index
    @collection = Hotel.page(params[:page] || 1).per(10)
  end
end
