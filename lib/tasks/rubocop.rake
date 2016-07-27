# frozen_string_literal: true
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:ruby) do |t|
  t.options = ['-D']
end

# Alias `rake lint` to rubocop task
task lint: [:ruby]

# Add rubocop task to `rake test`
Rake::Task[:test].enhance [:ruby]
