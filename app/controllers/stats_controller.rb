class StatsController < ActionController::API
  include ActionController::MimeResponds

  def reply(message)
    respond_to do |format|
      format.html {
        render :plain => message
      }
    end
  end

  def process_csv(stats)
    r = ['Percent,Time,Calls,Min,Max,Date']
    stats.each do |stat|
      r.append("#{stat.percent},#{stat.time},#{stat.calls},#{stat.min},#{stat.max},#{stat.created_at.strftime('%d-%m-%Y')}")
    end
    r.join("\n")
  end

  def get
    user = User.find_by_token(params['token'])
    if user.nil?
      reply 'Invalid token'
    else
      stats = Stat.joins(:task).where(task: {name: params['name'], user: user})
      if stats.empty?
        reply "There are no statistics for this task"
      else
        reply process_csv(stats)
      end
    end
  end
end
