module AccountPayment
  extend ActiveSupport::Concern

  included do
    # purchase transaction
    has_many :purchase_transaction, class_name: 'Payment::PurchaseTransaction', inverse_of: :account, dependent: :destroy
  end

  def payment_subscribed_exists?()
    now = Time.now
    purchase_transaction.where('started_at <= ? AND ended_at >= ?', now, now).exists?
  end

  def payment_transaction_exists?(service, transaction_id)
    purchase_transaction.where(service: service, transaction_id: transaction_id).exists?
  end
end
