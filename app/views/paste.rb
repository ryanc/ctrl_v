class App
  module Views
    class Paste < Layout
      def paste
        @paste
      end

      def delete?
        signed_in? and @paste.user_id == @current_user.id
      end
    end
  end
end
