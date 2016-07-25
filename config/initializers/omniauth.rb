email_name_format = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'

saml_options = {
  assertion_consumer_service_url: ENV['SAML_REDIRECT_URL'],
  issuer: ENV['SAML_ISSUER'],
  idp_sso_target_url: ENV['SAML_SIGNIN_URL'],
  idp_cert_fingerprint: ENV['SAML_FINGERPRINT'],
  name_identifier_format: ENV['SAML_NAME_FORMAT'] || email_name_format
}

Rails.application.config.middleware.use OmniAuth::Builder do
  auth_provider = ENV['AUTH_PROVIDER'] || 'google_oauth2'
  google_id = ENV['GOOGLE_CLIENT_ID']
  google_secret = ENV['GOOGLE_CLIENT_SECRET']

  provider :developer if Rails.env.development? && auth_provider == 'developer'
  provider :google_oauth2, google_id, google_secret if auth_provider == 'google_oauth2'
  provider :saml, saml_options if auth_provider == 'saml'
end
