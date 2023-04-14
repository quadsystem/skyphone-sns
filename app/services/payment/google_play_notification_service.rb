class Payment::GooglePlayNotificationService < BaseService
  include Payment::Helper

  # @param message [Payment::GoogleNotificationInfo]
  def call(message)
    return unless validate_message(message)

    @message_id = message.message_id
    @notified_at = Time.at(message.event_time_millis / 1000.0)
    @notification_type = message.subscription_notification.notification_type
    @purchase_token = message.subscription_notification.purchase_token
    @subscription_id = message.subscription_notification.subscription_id

    @api_client = Payment::AndroidPublisherClient.new
    @subscription = @api_client.get_purchase_subscription(
      message.package_name,
      @subscription_id,
      @purchase_token)

    return if Payment::GooglePurchaseTransaction.where(message_id: @message_id).exists?

    transaction = create_transaction
    case @notification_type
    when 1, 2 then
      update_account_transaction
    end
  end

  private

  def create_transaction
    transaction = {
      notification_type: @notification_type,
      purchase_token: @purchase_token,
      subscription: @subscription,
      message_id: @message_id,
      notified_at: @notified_at.to_datetime
    }
    Payment::GooglePurchaseTransaction.create(transaction)
  end

  def update_account_transaction()
    account_transaction = Payment::PurchaseTransaction.where(
      service: 'google',
      transaction_id: original_order_id
    ).first
    if account_transaction.present?
      started_at = @subscription.start_time_millis.present? \
        ? Time.at(@subscription.start_time_millis / 1000.0) \
        : nil
      ended_at = @subscription.expiry_time_millis.present? \
        ? Time.at(@subscription.expiry_time_millis / 1000.0) \
        : nil
      if started_at.present? && ended_at.present?
        account_transaction.update(
          started_at: started_at,
          ended_at: ended_at
        )
      end
    end
  end

  # @param message [Payment::GoogleNotificationInfo]
  def validate_message(message)
    raise Payment::PurchaseError, 'invalid package_name' unless check_android_package_name?(message.package_name)

    subscription = message.subscription_notification
    return false if subscription.nil?

    raise Payment::PurchaseError, 'invalid subscription_id' unless subscription.subscription_id == Rails.application.config_for(:payment)['android_subscription_id']

    true
  end

  def original_order_id()
    @subscription.order_id.split('..')[0]
  end
end
