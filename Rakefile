# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'json'
require 'health_cards'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb', 'test/**/*_spec.rb']
end

desc 'Run RuboCop'
task :rubocop do
  RuboCop::RakeTask.new
end

task default: %i[test rubocop]

namespace :healthcards do
  desc 'generate VC'
  task :vc, [:credential_subject] do |_task, args|
    vc = HealthCards::VerifiableCredential.new(args[:credential_subject])
    vc.save_as_qrcode
    credential = vc.credential
    puts JSON.pretty_generate(credential)
  end
end
