require 'digest'
require 'login_status'

class AuthController < ApplicationController
  after_action :clear_status
  include Digest

  def clear_status
    LoginStatus.clear_status
  end

  def log_in
    if [params[:login], params[:password]].all? { |i| !i.nil? }
      @user = User.find_by_login(params[:login])
      if @user.nil?
        LoginStatus.status = 'Invalid username'
      else
        if @user.password == params[:password]
          LoginStatus.current_user = @user
          redirect_to auth_welcome_path
        else
          LoginStatus.status = 'Invalid password'
        end
      end
    end
  end

  def sign_up
    unless [params[:login].nil?]
      @user = User.find_by_login(params[:login])
      unless @user.nil?
        LoginStatus.status = 'User exists'
        return
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
          LoginStatus.current_user = @user
          redirect_to auth_welcome_path
        else
          LoginStatus.status = 'Passwords do not match'
        end
      else
        LoginStatus.status = 'User exists'
      end
    end
  end

  def welcome
    if LoginStatus::current_user.nil?
      redirect_to root_path
    end
  end

end