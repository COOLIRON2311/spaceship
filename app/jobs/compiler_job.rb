require 'fileutils'

class CompilerJob < ApplicationJob
  include ActiveJob::Locking::Serialized
  # queue_as :default
  def lock_key(*args)
    self.class.name
  end

  def resolve_stats_collector
    File.readlines('Makefile').each do |line|
      if line.include?('nvprof')
        return NvprofCollector
      end
    end
    StatsCollector
  end

  def perform(user, task)
    dir = "tmp/#{user.id}_#{task.id}"
    Dir.chdir(dir) do
      stats = resolve_stats_collector
      result = IO.popen('make 2>&1').read
      task.result = result
      task.save!
      stats.new(task, result)
    end
    FileUtils.rm_r(dir)
  end
end
