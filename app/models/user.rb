require "sequel"
require "bcrypt"

module Models
  class User < Sequel::Model(:user)
    attr_reader :password
    attr_accessor :password_confirmation

    def password=(password)
      @password = password
      self.password_hash = BCrypt::Password.create(password)
    end

    def authenticate(password)
      password_hash = BCrypt::Password.new(self.password_hash)
      password_hash == password
    end

    def email=(email)
      return nil if email.strip.empty?
      super(email)
    end
  end
end
