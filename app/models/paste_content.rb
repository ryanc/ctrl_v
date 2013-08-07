require "sequel"

module Models
  class Content < Sequel::Model(:paste_content)
    plugin :timestamps

    def to_s
      self.content
    end
  end
end
