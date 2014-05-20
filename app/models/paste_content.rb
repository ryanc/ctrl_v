require 'sequel'

module Models
  # Paste content model
  class Content < Sequel::Model(:paste_content)
    plugin :timestamps

    def content=(content)
      # Strip extra whitespace.
      content.strip!

      # Replace CRLF with LF.
      content.gsub! /\r\n?/, "\n"

      self.digest = Digest::MD5.hexdigest(content)
      super(content)
    end

    def to_s
      self.content
    end
  end
end
