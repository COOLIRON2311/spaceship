require 'bcrypt'

class User < ApplicationRecord
  include BCrypt
  has_many :tasks
  has_many :ips

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end
