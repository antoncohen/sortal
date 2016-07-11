require 'sortal/jira'

class SubmitController < ApplicationController
  def jira
    logger.debug params[:jira][:subject]
    logger.debug params[:jira][:body]

    issue = Sortal::JIRA::Issue.new
    issue.summary = params[:jira][:subject]
    issue.description = params[:jira][:body]
    issue.issuetype = params[:jira][:type] || 'Task'
    submitted_issue = issue.submit

    begin
      @html_header = 'JIRA issue submitted'
      @html_text = "Your issue is #{submitted_issue.fetch('key')}"
    rescue KeyError
      @html_header = 'JIRA issue failed to submit'
      @html_text = "Error: #{submitted_issue['errors']}"
    end
  end
end
