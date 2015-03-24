require 'rake'

# We want to provide a way to alias tasks so we can hook our custom logic
# into the existing rails framework. For more information and usage, see:
# http://www.metaskills.net/2010/5/26/the-alias_method_chain-of-rake-override-rake-task
Rake::TaskManager.class_eval do
  def alias_task(fq_name)
    new_name = "#{fq_name}:original"
    @tasks[new_name] = @tasks.delete(fq_name)
  end
end

def alias_task(fq_name)
  Rake.application.alias_task(fq_name)
end

def override_task(*args, &block)
  name, params, deps = Rake.application.resolve_args(args.dup)
  fq_name = Rake.application.instance_variable_get(:@scope).dup.to_a.push(name).join(':')
  alias_task(fq_name)
  Rake::Task.define_task(*args, &block)
end