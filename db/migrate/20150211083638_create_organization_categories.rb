class CreateOrganizationCategories < ActiveRecord::Migration
  def normalize_title(title)
    title.mb_chars.downcase.capitalize
  end

  def create_organization_categories
    Organization.basic_suborganization_kinds.each do |kind|
      parent_title = normalize_title(I18n.t("organization.kind.#{kind}"))

      category = OrganizationCategory.create!(:title => parent_title)

      Values.instance.values.send(kind).categories.each do |v|
        title = normalize_title(v)

        next if parent_title == title

        category.children.create! :title => title
      end
    end
  end

  def set_categories_for_organizations_with_suborganizations
    Organization.basic_suborganization_kinds.each do |kind|
      category_title = normalize_title(I18n.t("organization.kind.#{kind}"))
      category = OrganizationCategory.find_by_title!(category_title)

      kind.classify.constantize.includes(:organization).each do |suborg|
        suborg.categories.each do |title|
          c = category.subtree.where(:title => normalize_title(title)).first

          suborg.organization.organization_categories << c
        end

        if suborg.categories.empty?
          category_title = normalize_title(I18n.t("organization.kind.#{kind}"))
          category = OrganizationCategory.find_by_title!(category_title)

          suborg.organization.organization_categories << category
        end
      end
    end
  end

  def set_categories_for_organizations_without_suborganizations
    Organization.includes(Organization.available_suborganization_kinds).select { |o| o.suborganizations.empty? }.each do |o|
      category_title = normalize_title(I18n.t("organization.kind.#{o.priority_suborganization_kind}"))
      category = OrganizationCategory.find_by_title!(category_title)

      o.organization_categories << category
    end
  end

  def up
    create_table :organization_categories do |t|
      t.string :title
      t.string :ancestry

      t.timestamps
    end
    add_index :organization_categories, :ancestry

    create_table :organization_categories_organizations, :id => false do |t|
      t.references :organization_category
      t.references :organization
    end
    add_index :organization_categories_organizations, [:organization_category_id, :organization_id], :uniq => true, :name => 'organization_organization_category'

    create_organization_categories
    set_categories_for_organizations_with_suborganizations
    set_categories_for_organizations_without_suborganizations
  end

  def down
    drop_table :organization_categories_organizations
    drop_table :organization_categories
  end
end
