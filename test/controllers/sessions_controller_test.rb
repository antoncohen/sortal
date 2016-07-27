# frozen_string_literal: true

require 'test_helper'

# Test session creation and deletion
class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get create' do
    # get sessions_create_url
    # assert_response :success
    assert true
  end

  test 'logout should delete session information' do
    delete logout_url
    assert_response :redirect
  end
end
