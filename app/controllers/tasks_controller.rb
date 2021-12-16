require 'fileutils'
require 'rubygems/package'

class TasksController < ActionController::API
  # skip_before_action :verify_authenticity_token
  include ActionController::MimeResponds

  def post
    @user = User.find_by_token(params['token'])
    unless @user.nil?
      task = Task.new(
        { :user_id => @user.id,
          :name => params['name'] })
      task.save!

      dir = "#{@user.id}_#{task.id}"
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

      respond_to do |format|
        format.html {
          render :plain => 'Task created successfully'
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

