require "sequel"

module Models
  class Content < Sequel::Model(:paste_content)
    def content=(content)
      content.strip!
      self.digest = Digest::MD5.hexdigest(content)
      super(content)
    end

    def to_s
      self.content
    end
  end
end
