class ApplicationController < ActionController::Base
  include JSONAPI::ActsAsResourceController
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def context
    {
      user: nil,
      policy: request.headers['HTTP_POLICY']
    }
  end
end
