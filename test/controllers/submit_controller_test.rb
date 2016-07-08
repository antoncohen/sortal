require 'test_helper'

class SubmitControllerTest < ActionDispatch::IntegrationTest
  test "should get jira" do
    get submit_jira_url
    assert_response :success
  end

end
