class My::DialogsController < My::ApplicationController
  skip_authorization_check
  def index
    @dialogs = current_user.account.dialogs.page(params[:page]).per(3)
    render partial: 'my/dialogs/list'
  end

  def show
    @dialog_with = Account.find(params[:id])
    @messages = PrivateMessage.dialog(current_user.account.id, @dialog_with.id).order('id ASC')
    @private_message = current_user.account.produced_messages.new(account_id: @dialog_with.id)
  end
end
