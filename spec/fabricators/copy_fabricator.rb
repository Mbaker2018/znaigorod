Fabricator :copy do
  copy_payment
end

# == Schema Information
#
# Table name: copies
#
#  id              :integer          not null, primary key
#  state           :string(255)
#  code            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  copy_payment_id :integer
#  copyable_id     :integer
#  copyable_type   :string(255)
#  row             :integer
#  seat            :integer
#

