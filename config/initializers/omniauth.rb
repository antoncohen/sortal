google_options = {
  name: :openid_connect,
  issuer: 'https://accounts.google.com',
  scope: [:openid, :email],
  response_type: :code,
  client_options: {
    discovery: true,
    port: 443,
    scheme: 'https',
    host: ENV['OPENID_CONNECT_HOST'],
    identifier: ENV['OPENID_CONNECT_CLIENT_ID'],
    secret: ENV['OPENID_CONNECT_CLIENT_SECRET'],
    redirect_uri: ENV['OPENID_CONNECT_REDIRECT_URI'],
    authorization_endpoint: '/o/oauth2/v2/auth',
    token_endpoint: 'https://www.googleapis.com/oauth2/v4/token',
    userinfo_endpoint: 'https://www.googleapis.com/oauth2/v3/userinfo'
  }
}

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?
  provider :google_oauth2, ENV['OPENID_CONNECT_CLIENT_ID'], ENV['OPENID_CONNECT_CLIENT_SECRET']
  provider :openid_connect, google_options
end
