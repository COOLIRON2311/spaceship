class TasksController < ActionController::API
  # skip_before_action :verify_authenticity_token
  include ActionController::MimeResponds

  def create
    @user = User.find_by_token(params['token'])
    unless @user.nil?
      print @user
      task = Task.new(
        { :user_id => @user.id,
          :name => params['name'] })
      task.save!
      respond_to do |format|
        format.html {
          render :plain => "Task successfully created"
        }
      end
    end
  end

  def result
    @user = User.find_by_token(params[:token])
    unless @user.nil?
      task = Task.where(user_id: @user.id).last
      respond_to do |format|
        format.json {
          render :text => task.result.nil? ? "Task execution has not finished yet" : task.result
        }
      end
    end
  end
end

