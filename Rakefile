require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

def alias_task(tasks)
    tasks.each do |new_name, old_name|
        task new_name, [*Rake.application[old_name].arg_names] => [old_name]
    end
end

alias_task [
    [:test, :spec]
]