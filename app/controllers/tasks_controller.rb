require 'fileutils'
require 'rubygems/package'

class TasksController < ActionController::API
  # skip_before_action :verify_authenticity_token
  include ActionController::MimeResponds

  def extract_tar(data, dest)
    Gem::Package::TarReader.new(data) do |tar|
      tar.each do |file|
        out = File.join(dest, file.full_name)
        if file.directory?
          FileUtils.mkdir_p(out)
        else
          out_dir = File.dirname(out)
          FileUtils.mkdir_p(out_dir) until File.directory?(out_dir)
          File.open(out, 'wb') do |f|
            # puts file.full_name
            f.print file.read
          end
        end
      end
    end
  end

  def reply(message)
    respond_to do |format|
      format.html {
        render :plain => message
      }
    end
  end

  def create
    @user = User.find_by_token(params['token'])
    if @user.nil?
      reply 'Invalid token'
    else
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
      extract_tar(data, dir)
      CompilerJob.perform_later(@user, task)
      reply 'Task created successfully'
    end
  end

  def result
    @user = User.find_by_token(params['token'])
    if @user.nil?
      reply 'Invalid token'
    else
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

