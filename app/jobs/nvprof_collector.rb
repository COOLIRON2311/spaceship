class NvprofCollector < StatsCollector
  def initialize(output)
    percent, time, calls, min, max = nil
    output.lines.each do |line|
      if line.include?(' GPU activities')
        percent, time, calls, min, max, _ = line.scan(/\s(\d+(?:\.\d+)*)/)
        break
      end
    end
    puts percent, time, calls, min, max
  end
end
