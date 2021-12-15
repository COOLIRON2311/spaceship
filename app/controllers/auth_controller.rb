require 'digest'
require 'login_status'

class AuthController < ApplicationController
  include ApplicationHelper
  include Digest

  def log_in
    if [params[:login], params[:password]].all? { |i| !i.nil? }
      @user = User.find_by_login(params[:login])
      if @user.nil?
        redirect_to auth_log_in_path, notice: 'Invalid username'
      else
        if @user.password == params[:password]
          session[:user_id] = @user.id
          redirect_to auth_welcome_path
        else
          redirect_to auth_log_in_path, notice: 'Invalid password'
        end
      end
    end
  end

  def sign_up
    unless params[:login].nil?
      @user = User.find_by_login(params[:login])
      unless @user.nil?
        redirect_to auth_sign_up_path, notice: 'User exists'
      end
    end
    if [params[:login], params[:password1], params[:password2]].all? { |i| !i.nil? }
      @user = User.find_by_login(params[:login])
      if @user.nil?
        if params[:password1] == params[:password2]
          @user = User.new({ :login => params[:login],
                             :password => params[:password1],
                             :token => MD5.hexdigest(params[:login] + params[:password1]) })
          @user.save!
          session[:user_id] = @user.id
          redirect_to auth_welcome_path
        else
          redirect_to auth_sign_up_path, notice: 'Passwords do not match'
        end
      else
        redirect_to auth_sign_up_path, notice: 'User exists'
      end
    end
  end

  def welcome
    if current_user.nil?
      redirect_to root_path
    end
  end
end