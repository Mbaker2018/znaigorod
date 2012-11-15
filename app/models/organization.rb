class Organization < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :address_attributes, :description, :email, :halls_attributes,
                  :images_attributes, :organization_id, :phone, :schedules_attributes,
                  :site, :title, :vfs_path, :attachments_attributes, :logotype_url,
                  :tour_link, :non_cash, :priority_suborganization_kind

  belongs_to :organization

  has_many :affiches,       :through => :showings, :uniq => true
  has_many :halls,          :dependent => :destroy
  has_many :images,         :as => :imageable,  :dependent => :destroy
  has_many :attachments,    :as => :attachable, :dependent => :destroy
  has_many :organizations,  :dependent => :destroy
  has_many :schedules,      :dependent => :destroy
  has_many :sauna_halls,    :through => :sauna
  has_many :showings,       :dependent => :destroy

  has_one :address,         :dependent => :destroy
  has_one :culture,         :dependent => :destroy
  has_one :entertainment,   :dependent => :destroy
  has_one :meal,            :dependent => :destroy
  has_one :sauna,           :dependent => :destroy

  validates_presence_of :title

  accepts_nested_attributes_for :address,   :reject_if => :all_blank
  accepts_nested_attributes_for :halls,     :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :images,    :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :attachments,    :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :schedules, :allow_destroy => true, :reject_if => :all_blank

  delegate :category, :cuisine, :feature, :offer, :payment,
           :to => :meal, :allow_nil => true, :prefix => true

  delegate :category, :feature, :offer, :payment,
           :to => :entertainment, :allow_nil => true, :prefix => true

  delegate :latitude, :longitude, :to => :address, :allow_nil => true

  scope :ordered_by_updated_at, order('updated_at DESC')
  scope :parental,              where(:organization_id => nil)

  before_save :set_rating
  after_save :index_additional_attributes

  alias_attribute :to_s, :title

  friendly_id :title, use: :slugged

  paginates_per Settings['pagination.per_page'] || 10

  has_one :organization_stand, :dependent => :destroy
  accepts_nested_attributes_for :organization_stand, :reject_if => :all_blank
  attr_accessible :organization_stand_attributes

  alias_attribute :poster_url, :logotype_url

  alias_attribute :title_ru, :title
  alias_attribute :title_translit, :title
  alias_attribute :category_ru, :category
  alias_attribute :cuisine_ru, :cuisine
  alias_attribute :feature_ru, :feature
  alias_attribute :offer_ru, :offer
  alias_attribute :payment_ru, :payment
  alias_attribute :address_ru, :address

  searchable do
    latlon(:location) { Sunspot::Util::Coordinates.new(latitude, longitude) }
    string(:kind) { 'organization' }
    text :title,                :boost => 1.0 * 1.2
    text :title_ru,             :boost => 1.0,              :more_like_this => true
    text :title_translit,       :boost => 0.0,                                        :stored => true
    text :category,             :boost => 0.5 * 1.2
    text :category_ru,          :boost => 0.5 * 1
    text :cuisine,              :boost => 0.5 * 1.2
    text :cuisine_ru,           :boost => 0.5 * 1,          :more_like_this => true,  :stored => true
    text :feature,              :boost => 0.5 * 1.2
    text :feature_ru,           :boost => 0.5 * 1,          :more_like_this => true,  :stored => true
    text :offer,                :boost => 0.5 * 1.2
    text :offer_ru,             :boost => 0.5 * 1,          :more_like_this => true,  :stored => true
    text :payment,              :boost => 0.5 * 1.2
    text :payment_ru,           :boost => 0.5 * 1,                                    :stored => true
    text :address,              :boost => 0.3 * 1.2
    text :address_ru,           :boost => 0.3,                                        :stored => true
    text :description,          :boost => 0.1 * 1.2                                                     do text_description end
    text :description_ru,       :boost => 0.1,                                        :stored => true   do text_description end

    float :rating

    text :term
  end

  def term
   "#{title}, #{address}"
  end

  def as_json(options)
    super(:only => :id, :methods => :term)
  end

  def nearest_affiches
    Affiche.where :id => Showing.unscoped.where('starts_at > :now AND organization_id = :organization_id',
                  { :now => DateTime.now.utc, :organization_id => id }).group(:affiche_id).pluck(:affiche_id)
  end

  def cuisine
    meal_cuisine
  end

  %w[category feature offer payment].each do |method|
    define_method method do
      [send("entertainment_#{method}"), send("meal_#{method}")].delete_if(&:blank?).compact.join(', ')
    end
  end

  %w[cuisine feature offer payment].each do |method|
    define_method "#{method}?" do
      send(method).present?
    end
  end

  def additional_attributes
    [meal, entertainment].compact
  end

  def index_additional_attributes
    additional_attributes.map(&:index)
  end

  def self.grouped_collection_for_select
    organizations = Organization.where(:organization_id => nil).order(:title)
  end

  def html_description
    @html_description ||= description.as_html
  end

  def text_description
    @text_description ||= html_description.as_text
  end

  def available_suborganization_kinds
    [:culture, :entertainment, :meal]
  end

  def priority_suborganization
    send priority_suborganization_kind
  end

  private

  def set_rating
    self.rating = nearest_affiches.count + images.count
    self.rating += 1 if description?
    self.rating += 1 if email?
    self.rating += 1 if phone?
    self.rating += 1 if tour_link?
    self.rating / 100.0
  end
end

# == Schema Information
#
# Table name: organizations
#
#  id              :integer          not null, primary key
#  title           :text
#  site            :text
#  email           :text
#  description     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  phone           :text
#  vfs_path        :string(255)
#  organization_id :integer
#  logotype_url    :text
#  slug            :string(255)
#  tour_link       :text
#  rating          :float
#  non_cash        :boolean
#

