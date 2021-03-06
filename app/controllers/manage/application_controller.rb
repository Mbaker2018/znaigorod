# encoding: utf-8

class Manage::ApplicationController < InheritedResources::Base
  helper_method :per_page, :namespace

  layout 'manage'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_manage_session_path, :notice => "У вас не хватает прав для выполнения этого действия"
  end

  check_authorization

  def per_page
    @per_page ||= Settings['pagination.per_page'] || 10
  end

  def namespace
    params[:controller].split('/').first
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, namespace)
  end
end
