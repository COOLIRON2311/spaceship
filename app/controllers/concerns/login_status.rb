class LoginStatus
  attr_accessor :status, :current_user

  public
  def new
    @status = ''
    @current_user = nil
  end

  def self.current_user
    @current_user
  end

  def self.current_user=(value)
    @current_user = value
    clear_status
  end

  def self.status
    @status
  end

  def self.status=(value)
    @status = value
  end

  def self.clear_status
    @status = ''
  end
end