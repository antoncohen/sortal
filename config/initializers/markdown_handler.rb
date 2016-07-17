require 'sortal/markdown'

# Render views ending in .md as markdown, converting them to HTML.
ActionView::Template.register_template_handler(
  :md,
  Sortal::Markdown::ViewHandler
)
