require 'rake/testtask'

namespace :test do
  task :health_cards do
    puts 'wwere'
    sh "cd lib/health_cards && bin/rake"
  end
end
