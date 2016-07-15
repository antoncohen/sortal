class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  skip_before_action :verify_authenticity_token, only: [:new, :create]

  def create
    session[:current_user] = {
      uid: request.env['omniauth.auth'][:uid],
      name: request.env['omniauth.auth'][:info][:name],
      email: request.env['omniauth.auth'][:info][:email]
    }

    redirect_to root_path
  end

  def destroy
    session.delete(:current_user)
    redirect_to root_path
  end
end
