class StatsController < ActionController::API
  include ActionController::MimeResponds

  def reply(message)
    respond_to do |format|
      format.html {
        render :plain => message
      }
    end
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
        reply stats.to_a
      end
    end
  end
end
