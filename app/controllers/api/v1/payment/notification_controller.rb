class Api::V1::Payment::NotificationController < Api::BaseController
  include Payment::Helper

  rescue_from JWT::DecodeError, with: :invalid_signed_payload

  skip_before_action :require_authenticated_user!

  def ios
    payload = Payment::AppleNotificationInfo.new(params[:signedPayload])
    Payment::AppleStoreServerNotificationService.new.call(payload)

    render_empty
  end

  def android
    message = Payment::GoogleNotificationInfo.new(params[:message])
    Payment::GooglePlayNotificationService.new.call(message)

    render_empty
  end

  private

  def create_params
    params.require(:notification).permit(:signedPayload)
  end
end
