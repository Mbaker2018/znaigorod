class ReviewMailer < ActionMailer::Base
  default :from => Settings['mail']['from']
  layout "review_notice_layout"

  def send_to_draft(review)
    @review = review
    mail :to => @review.account.email, :subject => "Ваш обзор #{@review.title} отправлен в черновики."
  end

  def send_to_published(review)
    @review = review
    mail :to => @review.account.email, :subject => "Ваш обзор #{@review.title} отправлен в опубликован"
  end

  def send_to_payment(review)
    @review = review
    mail :to => @review.account.email, :subject => "Ваш обзор #{@review.title} допущен к публикации."
  end

  def message_about_update(review)
    @review = review
    mail :to => Settings['mail']['to_review'], :from => @review.user.account.email, :subject => "Обзор #{@review.title} был изменён."
  end
end
