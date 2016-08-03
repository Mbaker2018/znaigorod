class TariffOrganizationPayment < Payment
  attr_accessible :amount, :tariff_id, :duration

  def approve!
    super

    set_tariff_organization
    create_notification_message
  end

  private

  def payment_system
    :robokassa
  end

  alias :organization :paymentable

  def set_tariff_organization
    OrganizationTariff.create(
      :organization_id => organization.id,
      :tariff_id => tariff_id,
      :duration => duration,
      :price => amount)
  end

  def create_notification_message
    if user
      NotificationMessage.delay(:queue => 'critical').create(:account => user.account, :kind => :set_tariff, :messageable => organization)
    end
  end
end

# == Schema Information
#
# Table name: payments
#
#  id               :integer          not null, primary key
#  paymentable_id   :integer
#  number           :integer
#  phone            :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#  paymentable_type :string(255)
#  type             :string(255)
#  amount           :float
#  details          :text
#  state            :string(255)
#  email            :string(255)
#

