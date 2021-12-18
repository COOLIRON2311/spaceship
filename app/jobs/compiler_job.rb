require 'fileutils'

class CompilerJob < ApplicationJob
  include ActiveJob::Locking::Serialized
  # queue_as :default
  def lock_key(*args)
    self.class.name
  end

  def perform(user, task)
    dir = "tmp/#{user.id}_#{task.id}"
    Dir.chdir(dir) do
      result = IO.popen('make').read
      task.result = result
      task.save!
    end
    FileUtils.rm_r(dir)
  end
end
