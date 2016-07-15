class ApplicationController < ActionController::Base
  before_action :require_login
  protect_from_forgery with: :exception

  helper_method :current_user

  private

  def require_login
    unless current_user
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

  def current_user
    session[:current_user]
  end
end
