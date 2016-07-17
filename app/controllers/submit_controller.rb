require 'set'

require 'sortal/jira'
require 'sortal/utils'

VALID_JIRA_ISSUE_TYPES = Set['Task', 'Story', 'Bug', 'Incident']
VALID_JIRA_PROJECTS = Set['TSP', 'TISD']

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
