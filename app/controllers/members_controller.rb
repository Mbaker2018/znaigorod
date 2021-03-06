class MembersController < ApplicationController
  inherit_resources

  load_and_authorize_resource

  actions :index, :create, :destroy

  belongs_to :discount, :optional => true

  has_scope :page, :default => 1

  layout false

  def index
    index! {
      @members = parent.members.page(params[:page]).per(3)
      render :partial => 'members', :locals => { :members => @members } and return }
  end

  def create
    create! {
      @members = parent.members.page(params[:page]).per(3)
      render :partial => 'social_block', :locals => { :discount => DiscountDecorator.new(parent) } and return
    }
  end

  def destroy
    destroy! {
      @members = parent.members.page(params[:page]).per(3)
      render :partial => 'social_block', :locals => { :discount => DiscountDecorator.new(parent) } and return
    }
  end

  protected

  def build_resource
    super
    @member.account = current_user.account if current_user

    @member
  end
end
