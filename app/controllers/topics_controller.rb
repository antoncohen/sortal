# frozen_string_literal: true

# Render markdown topics
class TopicsController < ApplicationController
  rescue_from ActionView::MissingTemplate, with: :not_found

  def index
  end

  def display
    render template: "topics/#{params[:section]}/#{params[:topic]}"
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found'), 'Not Found'
  end
end
