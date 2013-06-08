class App
  module ViewHelpers
    def gravatar(size = 32)
      gravitar_id = Digest::MD5.hexdigest(self[:email].to_s.strip.downcase)
      "//www.gravatar.com/avatar/#{gravitar_id}?s=#{size}"
    end
  end
end
