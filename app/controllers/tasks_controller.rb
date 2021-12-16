require 'fileutils'
require 'rubygems/package'

class TasksController < ActionController::API
  # skip_before_action :verify_authenticity_token
  include ActionController::MimeResponds

  def reply(message)
    respond_to do |format|
      format.html {
        render :plain => message
      }
    end
  end

  def post
    @user = User.find_by_token(params['token'])
    unless @user.nil?
      task = Task.where(user_id: @user.id).last
      if task && task.result.nil?
        reply 'You have unfinished tasks' # business
        return
      end

      task = Task.new(
        { :user_id => @user.id,
          :name => params['name'] })
      task.save!

      dir = "tmp/#{@user.id}_#{task.id}"
      FileUtils.mkdir_p(dir)

      data = StringIO.new(params['tar'])

      Gem::Package::TarReader.new(data) do |tar|
        tar.each do |file|
          File.open(File.join(dir, file.full_name), 'wb') do |f|
            # puts file.full_name
            f.print file.read
          end
        end
      end
      File.delete(File.join(dir, '@PaxHeader'))
      reply 'Task created successfully'
    end
  end

  def result
    puts params
    @user = User.find_by_token(params['token'])
    unless @user.nil?
      task = Task.where(user_id: @user.id).last
      print task
      if task.result.nil?
        reply "Task execution has not finished yet"
      else
        reply task.result
      end
    end
  end
end

