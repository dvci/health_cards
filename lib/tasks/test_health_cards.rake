# frozen_string_literal: true

require 'rake/testtask'

namespace :test do
  # rubocop:disable Rails/RakeEnvironment
  task :health_cards do
    sh 'cd lib/health_cards && bin/rake'
  end
  # rubocop:enable Rails/RakeEnvironment
end
