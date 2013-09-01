require "sequel"
require "bcrypt"

module Models
  class Sequel::Model
    def validates_password_confirmation(password)
      errors.add('password_confirmation', "The passwords must match.") unless send(password) == send('password_confirmation')
    end
  end

  class User < Sequel::Model(:user)
    plugin :timestamps
    plugin :validation_helpers

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
      validates_presence :username, :message => "The username cannot be blank."
      validates_presence :email, :message => "The email address cannot be blank."
      validates_presence :password, :message => "The password cannot be blank."
      validates_presence :password_confirmation, :message => "The password confirmation cannot be blank."
      validates_unique :username, :message => "The username is already taken."
      validates_unique :email, :message => "The email address has already been used."
      validates_password_confirmation :password
    end
  end
end
