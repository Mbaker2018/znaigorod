class AddOrganizationRequest
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :title, :address, :email,
    :phone, :payment_method, :open_time, :site

  validates_presence_of :title, :address, :email,
    :phone, :payment_method, :open_time, :site

  def initialize(attributes = {})
    attributes.each { |name, value| send "#{name}=", value }
  end

  def persisted?
    false
  end
end
