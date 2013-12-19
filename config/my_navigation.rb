# encoding: utf-8

SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :my, 'Личный кабинет', my_root_path, highlights_on: /^\/my[\/]?$|^\/my\/afisha[\/]?$/ do |my_item|
      my_item.item :new_afisha, 'Создание мероприятия', new_my_afisha_path
      my_item.item :afisha, @afisha.title || 'Нет названия', my_afisha_path(@afisha) do |afisha_item|
        afisha_item.item :first_step, 'Описание', edit_step_my_afisha_path(@afisha, :first)

        afisha_item.item :second_step, 'Постер', edit_step_my_afisha_path(@afisha, :second)

        afisha_item.item :fourth_step, 'Фотографии', edit_step_my_afisha_path(@afisha, :fourth)

        afisha_item.item :fifth_step, 'Видео', edit_step_my_afisha_path(@afisha, :fifth)

        afisha_item.item :fourth_step, 'Файлы', edit_step_my_afisha_path(@afisha, :sixth)

        afisha_item.item :showings, 'Расписание', new_my_afisha_showing_path(@afisha)

        afisha_item.item :showings, 'Расписание', edit_my_afisha_showing_path(@afisha, @showing) if @showing && @showing.persisted?
      end if @afisha && @afisha.persisted?

      my_item.item :posts, 'Мои посты', my_posts_path do |posts|
        posts.item :new, 'Добавление поста', new_my_post_path

        posts.item :post, @post.title, my_post_path(@post) do |post|
          post.item :edit, 'Редактирование поста', edit_my_post_path(@post)
        end if @post
      end if @post

      my_item.item :index, 'Добавление скидки', my_discounts_path
      my_item.item :new_discount, 'Добавление скидки', new_my_discount_path
      my_item.item :discount, @discount.title || 'Нет названия', my_discount_path(@discount) do |discount_item|
        discount_item.item :edit, 'Изменение информации', edit_my_discount_path(@discount)
        discount_item.item :poster, 'Постер', poster_my_discount_path(@discount)
      end if @discount && @discount.persisted?

      my_item.item :new_certificate, 'Добавление сертификата', new_my_certificate_path
      my_item.item :certificate, @certificate.title || 'Нет названия', my_discount_path(@certificate) do |certificate_item|
        discount_item.item :edit, 'Изменение информации', edit_my_discount_path(@discount)
        certificate_item.item :poster, 'Постер', poster_my_discount_path(@certificate)
      end if @certificate && @certificate.persisted?

      my_item.item :new_coupon, 'Добавление купона', new_my_coupon_path
      my_item.item :coupon, @coupon.title || 'Нет названия', my_discount_path(@coupon) do |coupon_item|
        discount_item.item :edit, 'Изменение информации', edit_my_discount_path(@discount)
        coupon_item.item :poster, 'Постер', poster_my_discount_path(@coupon)
      end if @coupon && @coupon.persisted?

    end
    primary.dom_class = 'breadcrumbs'
  end
end
