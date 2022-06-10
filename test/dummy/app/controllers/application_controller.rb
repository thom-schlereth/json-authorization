class ApplicationController < ActionController::Base
  include JSONAPI::ActsAsResourceController
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def context
    {
      user: nil,
      status_type: request.headers['HTTP_STATUS_TYPE']
    }
  end
end
