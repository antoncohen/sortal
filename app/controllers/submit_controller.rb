require 'set'

require 'sortal/email'
require 'sortal/jira'
require 'sortal/utils'

require 'rfc822'

VALID_JIRA_ISSUE_TYPES = Set['Task', 'Story', 'Bug', 'Incident'] # TODO: replace
VALID_JIRA_PROJECTS = Set['TSP', 'TISD'] # TODO: replace

VALID_EMAIL_TO = Set['help@example.com'] # TODO: replace
VALID_EMAIL_FROM_DOMAINS = Set['example.com'] # TODO: replace

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
      ENV['JIRA_DEFAULT_PROJECT'],
      'TSP'
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

    raise ActionController::UnpermittedParameters.new, [:to] unless VALID_EMAIL_TO.include?(to)
    raise ActionController::UnpermittedParameters.new, [:from] unless from.is_email?

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
