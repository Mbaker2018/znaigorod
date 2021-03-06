# == Schema Information
#
# Table name: tickets
#
#  id                 :integer          not null, primary key
#  afisha_id          :integer
#  number             :integer
#  original_price     :float
#  price              :float
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  description        :text
#  stale_at           :datetime
#  organization_price :float
#  email_addresses    :text
#  undertow           :integer
#  state              :string(255)
#  payment_system     :string(255)
#  short_description  :string(255)
#

require 'spec_helper'

describe Ticket do
  let(:ticket) { Fabricate :ticket }

  describe 'creates copies' do
    subject { ticket }

    its(:copies_count) { should == ticket.number }
  end
end
