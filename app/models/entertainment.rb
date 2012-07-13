class Entertainment < ActiveRecord::Base
  attr_accessible :category, :feature, :offer, :payment

  belongs_to :organization

  delegate :title, :images, :address, :phone, :schedules, :halls,
           :site?, :site, :email?, :email, :description, :description?, :affiches,
           :latitude, :longitude, :nearest_affiches, :to => :organization

  def self.or_facets
    %w[category]
  end

  def self.facets
    %w[category payment feature offer]
  end

  def self.facet_field(facet)
    "#{model_name.underscore}_#{facet}"
  end

  delegate :last_image_time, :to => :organization, :prefix => true, :allow_nil => true
  searchable do
    facets.each do |facet|
      text facet
      string(facet_field(facet), :multiple => true) { self.send(facet).to_s.split(',').map(&:squish) }
      latlon(:location) { Sunspot::Util::Coordinates.new(latitude, longitude) }
    end

    time :organization_last_image_time, :trie => true, :stored => true
  end
end

# == Schema Information
#
# Table name: entertainments
#
#  id              :integer         not null, primary key
#  category        :text
#  feature         :text
#  offer           :text
#  payment         :string(255)
#  organization_id :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

