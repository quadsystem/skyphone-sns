# == Schema Information
#
# Table name: payment_apple_purchase_transactions
#
#  id                :bigint(8)        not null, primary key
#  notification_type :string
#  subtype           :string
#  notification_uuid :string
#  signed_date       :datetime
#  transaction_info  :json
#  renewal_info      :json
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Payment::ApplePurchaseTransaction < ApplicationRecord
end
