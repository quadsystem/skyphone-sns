class Api::V1::Payment::PurchaseController < Api::BaseController
  include Payment::Helper

  rescue_from JWT::DecodeError, with: :invalid_signed_payload
  rescue_from Payment::PurchaseError, Google::Apis::ClientError, with: :invalid_subscription

  before_action -> { doorkeeper_authorize! :read }, only: [:index]
  before_action -> { doorkeeper_authorize! :write }, only: [:ios, :android]
  before_action :require_user!

  def index
    purchased = current_user.account.payment_subscribed_exists?
    puts "purchased: #{purchased}"
    result = {
      purchased: purchased
    }
    render json: result
  end

  def ios
    payload = decode_jws(ios_purchase_params[:signedPayload])
    purchase_transaction = Payment::ApplePurchaseService.new.call(
      current_user.account,
      payload
    )
    puts "result: #{purchase_transaction}"
    # render json: purchase_transaction, serializer: REST::Payment::PurchaseTransactionSerializer
    render_empty
  end

  def android
    purchase_transaction = Payment::GooglePurchaseService.new.call(
      current_user.account,
      android_purchase_params
    )
    render_empty
  end

  private

  def ios_purchase_params
    params.permit(:signedPayload)
  end

  def android_purchase_params
    params.permit(:subscription_id, :purchase_token)
  end
end
