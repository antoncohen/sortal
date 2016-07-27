# frozen_string_literal: true

require 'kramdown'

module Sortal
  module Markdown
    # Render markdown views.
    #
    # This Handler is designed to render view ending in .md.
    # It passes the template through ERB rendering first.
    #
    # @example In config/initializers/markdown_handler.rb add
    #   require 'sortal/markdown'

    #   ActionView::Template.register_template_handler(
    #     :md,
    #     Sortal::Markdown::ViewHandler
    #   )
    class ViewHandler
      def self.erb
        @erb ||= ActionView::Template.registered_template_handler(:erb)
      end

      def self.call(template)
        compiled_source = erb.call(template)
        "Kramdown::Document.new(begin;#{compiled_source};end, input: 'GFM').to_html"
      end
    end
  end
end
