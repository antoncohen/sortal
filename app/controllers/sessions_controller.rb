# Handle creating and destroying sessions stored as encrypted cookies
class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  skip_before_action :verify_authenticity_token, only: [:new, :create]

  # Create session with user data from auth
  #
  # Set cookie expiration in encrypted session so it can't be tampered with.
  def create # rubocop:disable Metrics/AbcSize,
    session[:current_user] = {
      uid: request.env['omniauth.auth'][:uid],
      name: request.env['omniauth.auth'][:info][:name],
      email: request.env['omniauth.auth'][:info][:email]
    }

    expires = ENV.fetch('SESSION_TIMEOUT', 600).to_i
    session[:expires_at] = expires.minutes.from_now.utc

    redirect_to root_path
  end

  # Delete session data to log-out user
  def destroy
    session.delete(:expires_at)
    session.delete(:current_user)
    redirect_to root_path
  end
end
