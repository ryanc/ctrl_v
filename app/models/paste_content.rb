require "sequel"

module Models
  class Content < Sequel::Model(:paste_content)
    plugin :timestamps

    def content=(content)
      content.strip!
      content.gsub! /\r\n?/, "\n"
      self.digest = Digest::MD5.hexdigest(content)
      super(content)
    end

    def to_s
      self.content
    end
  end
end
