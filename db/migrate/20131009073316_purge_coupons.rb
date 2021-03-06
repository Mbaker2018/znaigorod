class LegacyCoupon < ActiveRecord::Base
  set_table_name :coupons
end

class PurgeCoupons < ActiveRecord::Migration
  def up
    LegacyCoupon.destroy_all
    Copy.where(:copyable_type => 'Coupon').destroy_all

    drop_table :coupons
  end

  def down
  end
end
