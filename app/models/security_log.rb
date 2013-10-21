require "sequel"

module Models
  class SecurityLog < Sequel::Model(:security_log)
    plugin :timestamps
  end
end
