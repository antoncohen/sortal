# frozen_string_literal: true

ActionMailer::Base.smtp_settings = {
  address: ENV['EMAIL_SERVER'] || 'smtp.sendgrid.net',
  port: ENV['EMAIL_PORT'] || '587',
  authentication: :plain,
  user_name: ENV['EMAIL_USERNAME'] || ENV['SENDGRID_USERNAME'],
  password: ENV['EMAIL_PASSWORD'] || ENV['SENDGRID_PASSWORD'],
  domain: ENV['EMAIL_DOMAIN'] || 'heroku.com',
  enable_starttls_auto: true
}
