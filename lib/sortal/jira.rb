require 'erb'

# TODO: Write custom JIRA client

module Sortal
  module JIRA
    class Issue
      attr_accessor :project
      attr_accessor :summary
      attr_accessor :description
      attr_accessor :issuetype
      attr_accessor :reporter

      def initialize(
        project = ENV['JIRA_DEFAULT_PROJECT'],
        summary = nil,
        description = nil,
        issuetype = ENV.fetch('JIRA_DEFAULT_ISSUE_TYPE', 'Task'),
        reporter = nil
      )
        @project = project
        @summary = summary
        @description = description
        @issuetype = issuetype # TODO: Validate issue type
        @reporter = reporter
        options = {
          username: ENV['JIRA_USERNAME'],
          password: ENV['JIRA_PASSWORD'],
          site: ENV['JIRA_SITE'],
          context_path: '',
          auth_type: :basic
        }
        @client = ::JIRA::Client.new(options)
      end

      def search_username(username)
        puts @client.options[:site]
        puts @client.options[:username]
        puts @client.options[:password]
        users_url = @client.options[:rest_base_path] + '/user/search'
        query_params = "?username=#{ERB::Util.url_encode(username)}"
        response = @client.get(users_url + query_params)
        json = JSON.parse(response.body)
        json.map do |jira_user|
          @client.User.build(jira_user)
        end
      end

      def api_user
        search_username(ENV['JIRA_USERNAME'])[0]
      end

      def real_reporter(username)
        if username
          users = search_username(username)
          users.length == 1 ? users[0].name : api_user.name
        else
          api_user.name
        end
      end

      def submit
        issue_data = {
          fields: {
            project: {
              key: @project
            },
            summary: @summary,
            description: @description,
            issuetype: {
              name: '@issuetype'
            },
            reporter: {
              name: real_reporter(@reporter)
            }
          }
        }

        issue = @client.Issue.build
        issue.save(issue_data)
        issue
      end
    end
  end
end
