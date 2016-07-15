require 'set'

require 'sortal/jira'

VALID_JIRA_ISSUE_TYPES = Set['Task']
VALID_JIRA_PROJECTS = Set['TSP']

class SubmitController < ApplicationController
  def jira
    params.require(:jira).require([:subject, :body])
    params.require(:jira).permit([:project, :type])

    logger.debug params[:jira][:subject]
    logger.debug params[:jira][:body]

    username = current_user['email']

    issue = Sortal::JIRA::Issue.new
    issue.project = valid_jira_project(params[:jira][:project])
    issue.summary = params[:jira][:subject]
    issue.description = params[:jira][:body]
    issue.issuetype = valid_jira_issue_type(params[:jira][:type])
    issue.reporter = real_jira_reporter(username)
    submitted_issue = issue.submit

    begin
      @html_header = 'JIRA issue submitted'
      @html_text = "Your issue is #{submitted_issue.fetch('key')}"
    rescue KeyError
      @html_header = 'JIRA issue failed to submit'
      @html_text = "Error: #{submitted_issue}"
    end
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

  def valid_jira_issue_type(type)
    if VALID_JIRA_ISSUE_TYPES.include?(type)
      type
    else
      ENV.fetch('JIRA_DEFAULT_ISSUE_TYPE', 'Task')
    end
  end

  def valid_jira_project(project)
    if VALID_JIRA_PROJECTS.include?(project)
      project
    else
      ENV.fetch('JIRA_DEFAULT_PROJECT', 'TSP')
    end
  end
end
