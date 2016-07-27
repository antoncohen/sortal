# frozen_string_literal: true

# Base controller for this application
class ApplicationController < ActionController::Base
  before_action :require_login
  protect_from_forgery with: :exception

  helper_method :current_user

  private

  def require_login # rubocop:disable Metrics/MethodLength
    unless current_user && not_expired
      flash[:error] = 'Log-in Required'
      if Rails.env.development?
        if ENV['AUTH_PROVIDER']
          redirect_to "/auth/#{ENV['AUTH_PROVIDER']}"
        else
          redirect_to '/auth/developer'
        end
      else
        redirect_to "/auth/#{ENV['AUTH_PROVIDER']}"
      end
    end
  end

  # @return [Hash] of user info
  def current_user
    session[:current_user]
  end

  # @return [TrueClass,FalseClass] if non-expired session
  def not_expired
    !session[:expires_at].nil? && session[:expires_at] > Time.now.utc
  rescue ArgumentError
    false
  end
end
