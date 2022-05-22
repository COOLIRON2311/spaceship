class NvprofCollector < StatsCollector
  def initialize(task, output)
    percent, time, calls, min, max = nil
    output.lines.each do |line|
      if line.include?(' GPU activities')
        percent, time, calls, min, max, _ = line.scan(/\s(\d+(?:\.\d+)*(?:e[+-]\d*)?)/).flatten
        break
      end
    end
    s = Stat.new(task: task, percent: percent.to_f, time: time.to_f, calls: calls.to_i, min: min.to_f, max: max.to_f)
    s.save!
  end
end
