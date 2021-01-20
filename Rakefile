# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'json/canonicalization'
require_relative 'lib/health_cards/core_ext/canonicalization'
require_relative 'lib/health_cards/dids'
require_relative 'lib/health_cards/keys'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb', 'test/**/*_spec.rb']
end

desc 'Run RuboCop'
task :rubocop do
  RuboCop::RakeTask.new
end

desc 'Generates a random DID and prints out payload.'
task :did do
  include Dids
  include Keys
  enc_key = Keys.generate_key
  sign_key = Keys.generate_key
  update_key = Keys.generate_key
  rec_key = Keys.generate_key
  did = Dids.generate_did(enc_key[:publicJwk], sign_key[:publicJwk], update_key[:publicJwk], rec_key[:publicJwk])
  puts did[:didShort]
  puts did[:didLong]
  puts JSON.pretty_generate(Dids.resolve_did_long(did[:didLong]))
end

task default: %i[test rubocop]
