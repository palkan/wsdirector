# frozen_string_literal: true

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new

  RuboCop::RakeTask.new("rubocop:md") do |task|
    task.options << %w[-c .rubocop-md.yml]
  end
rescue LoadError
  task(:rubocop) {}
  task("rubocop:md") {}
end

desc "Run Ruby Next nextify"
task :nextify do
  sh "bundle exec ruby-next nextify -V"
end

task default: %w[rubocop rubocop:md spec]
