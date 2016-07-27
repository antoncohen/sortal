# frozen_string_literal: true

require 'set'

require 'sortal/email'
require 'sortal/jira'
require 'sortal/utils'

require 'rfc822'

VALID_JIRA_ISSUE_TYPES = Sortal::Utils.csv_to_set(
  ENV['VALID_JIRA_ISSUE_TYPES'],
  Set['Task', 'Story', 'Bug']
)
VALID_JIRA_PROJECTS = Sortal::Utils.csv_to_set(ENV['VALID_JIRA_PROJECTS'])

VALID_EMAIL_TO = Sortal::Utils.csv_to_set(ENV['VALID_EMAIL_TO'])
VALID_EMAIL_FROM_DOMAINS = Sortal::Utils.csv_to_set(ENV['VALID_EMAIL_FROM_DOMAINS'])

# Controller for submitting various types of issues/requests
class SubmitController < ApplicationController
  # Submit JIRA issues
  def jira # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    params.require(:jira).require([:subject, :body])
    params.require(:jira).permit([:subject, :body, :project, :type])

    username = current_user['email']

    issue = Sortal::JIRA::Issue.new
    issue.summary = params[:jira][:subject]
    issue.description = params[:jira][:body]
    issue.project = Sortal::Utils.valid_or_default(
      params[:jira][:project],
      VALID_JIRA_PROJECTS,
      ENV['JIRA_DEFAULT_PROJECT']
    )
    issue.issuetype = Sortal::Utils.valid_or_default(
      params[:jira][:type],
      VALID_JIRA_ISSUE_TYPES,
      ENV['JIRA_DEFAULT_ISSUE_TYPE'],
      'Task'
    )
    issue.reporter = real_jira_reporter(username)
    @submitted_issue = issue.submit
  end

  def email # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    params.require(:email).require([:to, :subject, :body])
    params.require(:email).permit([:to, :subject, :body])
    from = current_user['email']
    to = params[:email][:to]

    bad_param = ActionController::UnpermittedParameters
    raise bad_param.new([:to]), 'Invalid To address' unless VALID_EMAIL_TO.include?(to)
    raise bad_param.new[:from], 'User email address invalid' unless from.is_email?

    message = Sortal::Email::Message.new
    message.to = to
    message.from_address = from
    message.from_name = current_user['name']
    message.valid_from_domains = VALID_EMAIL_FROM_DOMAINS
    message.default_from = ENV['EMAIL_DEFAULT_FROM']
    message.subject = params[:email][:subject]
    message.body = params[:email][:body]
    message.build

    @submitted_message = SubmitMailer.email(message).deliver_now
  end

  # Get API user data
  #
  # JIRA supports logging in with an email address,
  # so ENV['JIRA_USERNAME'] could be an email address.
  #
  # JIRA only supports assigning an issue reporter by username.
  # This method is used to get the username of the API user.
  #
  # @return [Hash] user data
  def jira_api_user
    user = Sortal::JIRA::User.new
    user.myself
  end

  # Determines who the issue reporter should be
  #
  # Return the `username` if valid, otherwise search for the username
  # in case it is an email address.
  #
  # Fallback to using the API user if `username` doesn't exist.
  #
  # @return [String] username
  def real_jira_reporter(username = nil)
    # First check if username is a real username, not email
    userinfo = Sortal::JIRA::User.new(username)
    userinfo.get
    return userinfo.data['name'] if userinfo.data

    if username
      users = userinfo.search(username)
      users.length == 1 ? users[0]['name'] : jira_api_user['name']
    else
      jira_api_user['name']
    end
  end
end
