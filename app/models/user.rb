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

    def name=(name)
      return nil if name.strip.empty?
      super(name)
    end

    def validate
      super
      errors.add(:username, "The username '#{username}' is already taken.") unless model.where(:username => username).empty?
      errors.add(:username, 'The username cannot be blank.') if !username || username.strip.empty?
      errors.add(:email, 'The email address cannot be blank.') if !email || email.strip.empty?
      errors.add(:password, 'The password cannot be blank.') if !password || password.strip.empty?
      errors.add(:password_confirmation, 'The passwords do not match.') if password_confirmation || password != password_confirmation
    end
  end
end
