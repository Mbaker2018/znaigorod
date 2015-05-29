class ArchiveDiscount < MandrillMailer
  default :from => "znaigorod.ru"
  layout "notice_layout"

  def send_archived(account, discounts)
    @type = 'archive_discount'
    @account = AccountDecorator.decorate account
    @discounts = discounts

    mail(:to => account.email, :subject => "Ваша скидки перемещены в архив")
  end

  def send_warning(account, discounts)
    @type = 'archive_discount'
    @account = AccountDecorator.decorate account
    @discounts = discounts

    mail(:to => account.email, :subject => "Ваши скидки скоро будут перемещены в архив")
  end
end
