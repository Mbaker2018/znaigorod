SimpleNavigation::Configuration.run do |navigation|
  navigation.id_generator = Proc.new {|key| "main_menu_#{key}"}

  navigation.items do |primary|
    primary.item :afisha, 'Афиша', afisha_index_path, highlights_on: -> { controller_name == 'afishas' } do |afisha|
      Afisha.kind.values.each do |item|
        afisha.item "afisha_#{item}", I18n.t("enumerize.afisha.kind.#{item}") ,send("#{item.pluralize}_path")
      end
    end

    primary.item :organizations, 'Заведения', organizations_path,
      highlights_on: -> { %w[organizations suborganizations saunas].include? controller.class.name.underscore.split("_").first } do |organization|
      Organization.suborganization_kinds_for_navigation.drop(1).each do |suborganization_kind|
        organization.item suborganization_kind, I18n.t("organization.kind.#{suborganization_kind}"), send("#{suborganization_kind.pluralize}_path") do |category|
          "#{suborganization_kind.pluralize}_presenter".camelize.constantize.new.categories_links.each do |link|
            category.item "#{suborganization_kind}_#{link[:klass]}", link[:title], send(link[:url])
          end
        end
      end
    end

    primary.item :discounts, 'Скидки', discounts_path, highlights_on: -> { controller_name == 'discounts' } do |discount|
      Hash[Discount.kind.options].invert.each do |kind, title|
        discount.item kind, title, [:discounts, kind]
      end
    end

    primary.item :reviews, 'Обзоры', reviews_path, highlights_on: -> { controller_name == 'posts' } do |reviews|
      Hash[Review.categories.options].invert.each do |category, title|
        reviews.item category, title, [:reviews, category]
      end
    end

    primary.item :accounts, 'Знакомства', accounts_path, highlights_on: -> { controller_name == 'accounts' } do |account|
      Inviteables.instance.categories.keys.each do |item|
        account.item Russian::translit(item).gsub(/\s|\//, '_'), item, send("accounts_#{(transliterate(item))}_path")
      end
    end

    primary.item :more, 'Ещё', '#', :link => { :class => :disabled },
      highlights_on: -> { %w[contests posts works cooperation].include?(controller_name) } do |more|
      more.item :tickets, 'Распродажа билетов', afisha_with_tickets_index_path, highlights_on: -> { controller_name == nil }
      more.item :webcams, 'Веб-камеры', webcams_path, highlights_on: -> { controller_name == 'webcams' }
      more.item :contests, 'Конкурсы', contests_path, highlights_on: -> { %w[contests works].include? controller_name }
      more.item :services, 'Реклама', services_path, highlights_on: -> { controller_name == 'cooperation' }
      more.item :widgets, 'Виджеты', widgets_root_path, highlights_on: -> { controller_name.match(/widgets/i) }
      more.item :feedback, 'Отзывы и предложения', feedback_path, highlights_on: -> { controller_name == 'feedback' }
    end
  end
end